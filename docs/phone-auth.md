# Phone approval for sudo

Password **or** phone push. Type the password and nothing is sent to your
phone; press Enter on an empty prompt and a Duo push arrives instead. Either
factor alone grants sudo.

## Why not "phone only"

An Android/iOS phone **cannot** act as a FIDO2 authenticator for Linux PAM —
the caBLE/hybrid transport that makes phone passkeys work in browsers is not
implemented by `libfido2`, so `pam_u2f` cannot see a phone. Phone-based PAM auth
therefore means a cloud push service (Duo), a TOTP code you type, or DIY glue.

Duo push was chosen. It is kept as a *second* option rather than a replacement
because a phone that is lost, dead, stolen, or offline would otherwise be either
a full lockout or a full root compromise with nothing behind it. The password
remains the primary path.

## What is where, and why

| Thing | Location | Managed by | Why |
|---|---|---|---|
| PAM stack | `/etc/pam.d/sudo` | dotter (`root` package, `template`) | 0644, no secrets |
| sudoers | `/etc/sudoers` | `scripts/harden-auth.sh` | needs 0440 or sudo refuses it |
| Duo keys | `/etc/duo/pam_duo.conf` | `scripts/harden-auth.sh` | secret; this repo is **public** |

`type = "template"` copies content instead of symlinking. A symlink from
`/etc/pam.d/sudo` into this repo would let any process running as your user
rewrite the check that gates root — the same reasoning as the `keyd` entries.

## First-time setup on a new machine

1. `paru -S duo_unix`
2. Sign in at <https://duo.com> (Duo Free covers personal use), create a
   **UNIX Application**, enroll your phone, and copy its integration key,
   secret key, and API hostname.
3. Deploy the PAM stack:
   ```sh
   cd ~/dotfiles && sudo dotter -l .dotter/local-root.toml \
     --cache-file .dotter/cache-root.toml --cache-directory .dotter/cache-root \
     deploy --force
   ```
4. Harden sudo and write the Duo config:
   ```sh
   ~/scripts/harden-auth.sh --duo <IKEY> <SKEY> <API_HOST>
   ```
   It refuses to run if your account has no usable password hash, and it makes
   you authenticate once (`su` to yourself) to prove you actually *know* the
   password before it takes `NOPASSWD` away.
5. **Test in a second terminal, keeping the first one open:**
   ```sh
   sudo -k && sudo true          # expect a password prompt
   sudo -k && sudo true          # press Enter -> expect a push
   ```

Steps 1–2 are inherently manual: they need your email, your phone, and Duo's
own MFA. Everything after that is in this repo.

## If sudo breaks

```sh
su -              # root password
unharden-sudo     # restores /etc/sudoers.pre-harden.bak
```

`unharden-sudo` is installed by the script *before* it touches sudoers.

## Design notes

- **`pam_unix` runs first and is `sufficient`.** A correct password short-circuits
  the stack, so routine sudo never wakes your phone. This also keeps the
  push-fatigue surface at zero: a push only ever arrives because someone
  deliberately skipped the password prompt, so an unexpected push is real signal.
- **`failmode = secure`, not Duo's default `safe`.** `safe` *allows* access when
  Duo is unreachable. With a `sufficient` pam_duo that would silently restore
  passwordless sudo whenever the network was down — reintroducing the exact hole
  this closes. `secure` denies, and the password path is the intended fallback.
- **No `pam_faillock` in this stack.** `sufficient` on `pam_unix` returns before
  faillock's `authsucc` could reset the counter, so failures would accumulate
  until the account locked itself out for no reason. Brute-force defence stays
  on the login path (`system-auth`), which is where an attacker without a shell
  arrives; anyone who can invoke sudo is already running as you.
- **`timestamp_type` left at sudo's default `tty`.** With `global`, a process
  running as you in *any* terminal can reuse a timestamp minted in another —
  which is exactly the "malicious dependency silently becomes root" path being
  closed. Add `Defaults timestamp_type=global` to trade that back.
- **`/etc/sudoers` is edited directly, not via a drop-in.** On `barry`,
  `@includedir /etc/sudoers.d` was commented out, so the directory was never
  read and `/etc/sudoers.d/00_cjber` was dead config. A drop-in would have been
  silently ignored while `NOPASSWD` stayed live. The includedir is restored, but
  the `%wheel` rule is authoritative regardless.

## To make it true 2FA (password AND phone)

In `etc/pam.d/sudo`: make `pam_unix` `required`, make `pam_duo` `required`,
drop `pam_deny`. Then redeploy the root package. Expect two steps per sudo, and
recovery via `su -` if the phone is lost.
