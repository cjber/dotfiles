#!/usr/bin/env bash
# Mirrors this machine's Claude Code + Codex setup onto the NAS, so background
# sessions handed off there (see nas-handoff.sh) behave like local ones.
# Re-runnable: every step overwrites or merges, none appends.
#
#   nas-sync.sh          config, skills, memory, codex, git identity
#   nas-sync.sh --auth   also re-copy gcloud + codex credentials
set -euo pipefail

nas=nas
rhome=/home/cillian
say() { printf '\033[1m%s\033[0m\n' "$*"; }
# The NAS login shell is bash; -l puts ~/.local/bin (claude, gh, uv) on PATH.
rsh() { ssh "$nas" "bash -lc $(printf '%q' "$1")" 2>&1 | grep -v -e 'post-quantum' -e 'store now' -e 'openssh.com/pq' || true; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# The NAS's rsync is a restricted wrapper that rejects every path (so does its
# scp), so files travel as tar over ssh. -h dereferences skill symlinks.
# mirror <local-dir> <remote-dir>: replace the remote dir with the local one.
mirror() { tar chf - -C "$1" . | ssh "$nas" "rm -rf '$2' && mkdir -p '$2' && tar xf - -C '$2'"; }
# put <remote-dir> <local-file>...: copy files into a remote dir.
put() { local d=$1; shift; tar chf - "$@" | ssh "$nas" "mkdir -p '$d' && tar xf - -C '$d'"; }

say "claude: CLAUDE.md, skills, statusline"
mirror ~/.claude/skills "$rhome/.claude/skills"
(cd ~/.claude && put "$rhome/.claude" statusline.py subagent-statusline.py)
# The global CLAUDE.md plus the facts only true on the NAS.
cat ~/.claude/CLAUDE.md ~/dotfiles/claude/nas-notes.md >"$tmp/CLAUDE.md"
(cd "$tmp" && put "$rhome/.claude" CLAUDE.md)

say "claude: settings.json (minus desktop-only hooks and voice)"
# Every hook calls agent-deck or orca, desktop apps the NAS does not run; an
# absent agent-deck turns each event into a hook error. No mic, so no voice.
jq 'del(.hooks, .voice, .voiceEnabled)' ~/.claude/settings.json >"$tmp/settings.json"
(cd "$tmp" && put "$rhome/.claude" settings.json)

say "claude: plugins"
rsh 'claude plugin marketplace add https://github.com/ComposioHQ/composio-plugin-cc.git >/dev/null 2>&1 || true
     for p in composio@composio lua-lsp@claude-plugins-official; do claude plugin install "$p" >/dev/null 2>&1 || echo "plugin $p: install failed"; done'

say "claude: nebula memory (both ways, newer file wins)"
# NAS worktrees of ~/code/nebula all resolve to this one project memory dir.
lmem=~/.claude/projects/-home-cjber-drive-agl-nebula/memory
rmem=$rhome/.claude/projects/-home-cillian-code-nebula/memory
tar cf - -C "$lmem" . | ssh "$nas" "mkdir -p '$rmem' && tar xf - --keep-newer-files -C '$rmem' 2>/dev/null; true"
ssh "$nas" "tar cf - -C '$rmem' ." | tar xf - --keep-newer-files -C "$lmem" 2>/dev/null || true
# Both sides append to the index, so newer-wins would drop the other side's
# lines. Union them instead: local order, then lines only the NAS has.
ssh "$nas" "cat '$rmem/MEMORY.md'" >"$tmp/nas-index.md"
awk '!seen[$0]++' "$lmem/MEMORY.md" "$tmp/nas-index.md" >"$tmp/MEMORY.md"
cp "$tmp/MEMORY.md" "$lmem/MEMORY.md"
(cd "$tmp" && put "$rmem" MEMORY.md)

say "codex: CLI"
rsh 'npm install -g --prefix ~/.local @openai/codex@latest >/dev/null 2>&1 && codex --version'

say "codex: config, AGENTS.md, rules, skills"
# [projects."<path>"] trust tables name this machine's paths; replace them with
# the NAS code root. Skill paths are absolute, so re-home them.
python3 - ~/.codex/config.toml "$rhome" >"$tmp/config.toml" <<'EOF'
import re, sys
src, rhome = open(sys.argv[1]).read(), sys.argv[2]
out, skip = [], False
for line in src.splitlines():
    if re.match(r"^\[", line):
        skip = line.startswith("[projects.")
    if not skip:
        out.append(line)
text = "\n".join(out).replace("/home/cjber", rhome)
print(text.rstrip() + f'\n\n[projects."{rhome}/code"]\ntrust_level = "trusted"\n')
EOF
for f in deep economy; do sed "s#/home/cjber#$rhome#g" ~/.codex/$f.config.toml >"$tmp/$f.config.toml"; done
cp ~/.codex/AGENTS.md "$tmp/"
(cd "$tmp" && put "$rhome/.codex" config.toml deep.config.toml economy.config.toml AGENTS.md)
mirror ~/.codex/rules "$rhome/.codex/rules"
mirror ~/.codex/skills "$rhome/.codex/skills"

say "git: global identity + ssh signing"
rsh 'git config --global user.name cjber
     git config --global user.email cillian@nebula.gg
     git config --global gpg.format ssh
     git config --global user.signingkey ~/.ssh/cjber_nebula_ed25519.pub
     git config --global gpg.ssh.allowedSignersFile ~/.ssh/cjber_allowed_signers
     git config --global commit.gpgsign true
     git config --global tag.gpgsign true
     git config --global core.fileMode false'

say "remote control: claude-rc@nebula (phone-startable sessions)"
# Same script as this machine's units, rooted at ~/code and named nas-* so the
# app tells them apart. Linger is on, so it runs with nobody logged in.
cat >"$tmp/claude-rc@.service" <<'EOF'
[Unit]
Description=Claude Code Remote Control server for %i (NAS)
After=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
Environment=CLAUDE_RC_ROOT=%h/code CLAUDE_RC_PREFIX=nas-
ExecStart=%h/scripts/claude-rc.sh %i
Restart=always
RestartSec=15
StandardOutput=null
StandardError=journal

[Install]
WantedBy=default.target
EOF
(cd ~/dotfiles/scripts && put "$rhome/scripts" claude-rc.sh)
(cd "$tmp" && put "$rhome/.config/systemd/user" 'claude-rc@.service')
# Remote Control refuses an untrusted workspace and nobody ever opens claude
# interactively in ~/code/nebula there, so accept its trust dialog up front.
rsh 'cd ~ && jq ".projects[\"$HOME/code/nebula\"].hasTrustDialogAccepted = true" .claude.json >.claude.json.tmp &&
     mv .claude.json.tmp .claude.json &&
     chmod +x ~/scripts/claude-rc.sh && systemctl --user daemon-reload &&
     systemctl --user enable claude-rc@nebula >/dev/null 2>&1 && systemctl --user restart claude-rc@nebula'

say "timer: daily prune of merged worktrees"
# A user timer, not cron: the NAS's /var/spool/cron is not writable by cillian.
# prune.sh only, never freshen.sh: ~/code/nebula can be checked out on a branch
# by a live session, and freshen would move it to main underneath that session.
cat >"$tmp/wt-prune.service" <<'EOF'
[Unit]
Description=Prune merged nebula worktrees (NAS)

[Service]
Type=oneshot
ExecStart=/bin/bash -lc 'bash ~/.claude/skills/wt/prune.sh ~/code/nebula'
EOF
cat >"$tmp/wt-prune.timer" <<'EOF'
[Unit]
Description=Daily prune of merged nebula worktrees (NAS)

[Timer]
OnCalendar=*-*-* 05:30
Persistent=true

[Install]
WantedBy=timers.target
EOF
(cd "$tmp" && put "$rhome/.config/systemd/user" wt-prune.service wt-prune.timer)
rsh 'systemctl --user daemon-reload && systemctl --user enable --now wt-prune.timer >/dev/null 2>&1'

if [ "${1-}" = "--auth" ]; then
    say "auth: gcloud + codex"
    tar czf - -C ~/.config --exclude='gcloud/logs' --exclude='gcloud/.last_*' gcloud |
        ssh "$nas" 'mkdir -p ~/.config && tar xzf - -C ~/.config && chmod -R go-rwx ~/.config/gcloud'
    (cd ~/.codex && put "$rhome/.codex" auth.json) && ssh "$nas" "chmod 600 $rhome/.codex/auth.json"
fi

say "check"
rsh 'claude --version; codex --version; codex login status 2>&1 | head -1; gcloud auth list --format="value(account)" 2>&1 | head -2; git config --global gpg.format'
