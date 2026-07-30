# Disk encryption + Secure Boot plan (`barry`)

Status: **plan only, not executed.** This cannot be done safely in place; it is
a backup-first, scheduled operation with a real chance of an unbootable system
partway through.

## Current state (measured 2026-07-30)

| | |
|---|---|
| Root | `/dev/nvme0n1p2`, btrfs, subvol `@`, UUID `9638e766-3efc-44d0-a3e0-5e5002064ab0` |
| Size / used | 954 G / 652 G used, 281 G free (70 %) |
| Subvolumes | `@`, `@home`, `@log`, `@pkg`, `@swap`, `@.snapshots`, + 8 timeshift snapshots |
| ESP | `/dev/nvme0n1p1`, vfat, **512 M, 445 M used — 67 M free (88 %)** |
| Bootloader | GRUB 2.14~rc1 |
| Encryption | **none** |
| Secure Boot | disabled; TPM2 present (`/dev/tpm0`), unused |
| initramfs | `HOOKS=(base udev microcode autodetect keyboard keymap modconf block filesystems fsck)` — no `encrypt`/`sd-encrypt` |
| initramfs MODULES | `btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm` — **out-of-tree** |
| Second disk | `/dev/nvme1n1`, 1.9 T, Windows (plain NTFS, not BitLocker) |

## Threat model first — this is the part worth arguing about

Full-disk encryption defends against **offline access to the drive**: theft,
RMA, resale, a burglar, someone booting a USB stick. It does **nothing** against
a running system, a malicious dependency, or a remote attacker — those are what
the sudo hardening addresses.

`barry` is a desktop that lives at one address. The realistic FDE payoff here is
"the drive leaves the house without me". That is genuine but modest, and it costs
a passphrase at every boot plus a nontrivial migration.

**The laptop is the machine that actually needs this.** A laptop leaves the
building. If effort is limited, encrypt the laptop first and treat `barry` as
optional. That machine was not inspected here — it needs its own survey before
any of this applies to it.

## Why in-place conversion is not recommended

`cryptsetup reencrypt --encrypt --reduce-device-size` can encrypt a LUKS2
device in place, but it needs free space at the *start* of the partition for the
header, which means shrinking the filesystem first. On btrfs that is
`btrfs filesystem resize` plus a partition-table edit on the live root device,
with 8 timeshift snapshots and a swap subvolume in the way. An interruption
(power loss, a bad resize) mid-reencrypt on a 954 G device with no verified
restore path loses everything.

Restore-from-backup is slower but each step is independently verifiable, and it
is the only version of this where a failure is recoverable.

## Plan

### Phase 0 — prove the backup (do this regardless of the rest)

`scripts/restic-backup.sh` already exists. Untested restores are not backups.

1. `restic snapshots` — confirm recent, complete snapshots exist.
2. Restore a sample to scratch space and diff it against the live tree.
3. Confirm what is *excluded* (`scripts/restic-excludes.txt`) is genuinely
   reproducible — anything not in the backup and not in a git remote is lost.
4. Separately note anything not covered by restic at all: GPG/SSH private keys,
   `.env` files, browser profiles, Steam library (re-downloadable), and the
   contents of `~/drive`.

**If phase 0 does not pass, stop. Nothing below is safe.**

### Phase 1 — enlarge the ESP

A 512 M ESP at 88 % is already tight for two kernels plus fallback initramfs.
It cannot hold signed Unified Kernel Images (a UKI bundles kernel + initramfs +
microcode; roughly 100–150 M each with the NVIDIA modules present). Secure Boot
via UKI is blocked until this is fixed, and it is easiest to fix during a
reinstall when the partition table is being rewritten anyway.

Target: **1 G minimum, 2 G comfortable.**

### Phase 2 — LUKS2 + restore

1. Boot the Arch ISO. Confirm the backup is reachable *from the ISO* before
   destroying anything.
2. `cryptsetup luksFormat --type luks2 /dev/nvme0n1p2` (Argon2id; keep the
   default memory cost unless the ISO struggles).
3. Recreate the btrfs subvolume layout: `@`, `@home`, `@log`, `@pkg`, `@swap`,
   `@.snapshots`. Note `@swap` needs `nodatacow` and no compression to be a
   valid swapfile host.
4. Restore from restic.
5. `HOOKS`: add `sd-encrypt` — and switch to the systemd initramfs (`systemd`
   in place of `base udev`, `sd-vconsole` in place of `keymap`), which is
   required for `sd-encrypt` and for TPM2 unlocking in phase 3.
6. Kernel cmdline: `rd.luks.name=<UUID>=root root=/dev/mapper/root
   rootflags=subvol=@`. Keep the existing `nvidia-drm.modeset=1` flags.
7. Regenerate initramfs and GRUB config. **Verify a boot to a passphrase prompt
   before doing anything else.**

Do not skip a working passphrase boot to go straight to TPM2 unlock. The
passphrase is the recovery path for every later step.

### Phase 3 — TPM2 auto-unlock (optional, after a passphrase boot works)

`systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7+11 /dev/nvme0n1p2`
Needs `tpm2-tools` (not currently installed).

**This is only meaningful with Secure Boot enabled.** PCR 7 measures Secure Boot
state and PCR 11 the UKI; without Secure Boot, sealing to the TPM lets anyone
who boots the machine unlock the disk — it converts FDE into "protects against a
stolen drive only, not a stolen machine". That may still be the right trade for a
desktop, but it should be a decision, not an accident. Always keep the
passphrase enrolled as a recovery key.

### Phase 4 — Secure Boot (the hard one, because of NVIDIA)

`sbctl` (not installed) creates custom keys, enrolls them, and signs boot
artifacts.

The complication: **the proprietary NVIDIA modules are in the initramfs and are
out-of-tree.** Under Secure Boot with kernel lockdown, unsigned out-of-tree
modules are refused, so every NVIDIA DKMS rebuild must be signed with an
enrolled MOK, and a kernel or driver update that rebuilds without signing yields
a machine with no graphics — on a Hyprland-only system that means no usable
session. This needs a pacman hook to sign DKMS modules on every rebuild, set up
and tested *before* enabling Secure Boot in firmware.

Dual-boot note: Windows on `nvme1n1` is plain NTFS with no BitLocker, so
enabling Secure Boot will not trigger a BitLocker recovery prompt. Keep
Microsoft's keys enrolled (`sbctl enroll-keys --microsoft`) or Windows stops
booting.

Also required: a firmware admin password. Secure Boot with an unlocked firmware
menu is theatre — anyone with physical access turns it off.

## Recommended order

1. **Phase 0 now.** Verify the restic restore. This is worth doing on its own
   merits today and is a prerequisite for everything else.
2. **Survey the laptop and encrypt that first** — it is the machine with the real
   exposure.
3. `barry` phases 1–2 only if you are willing to spend an evening on a reinstall.
4. Phases 3–4 last, and only together. TPM2 without Secure Boot weakens the
   guarantee; Secure Boot without the NVIDIA signing hook breaks graphics.

Phases 1–4 are deliberately not automated. A script that repartitions and
reformats a live root disk is a footgun, and each phase needs a human to confirm
the machine still boots before the next one starts.
