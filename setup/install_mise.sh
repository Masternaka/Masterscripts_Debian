#!/usr/bin/env bash
# install_mise.sh — one-time bootstrap of mise on Debian Trixie: apt repo + package,
# then shell activation wired into your *login* shell's rc file.
#
# This is guide §1 + §2 (mise-dev-tools-test.md) as one idempotent, re-runnable
# script — and it's the same handful of steps butterknife's installer runs. It
# automates the brittle ONE-TIME bootstrap; it does NOT wrap mise's daily verbs
# (mise use / install / run are already terse — use them directly).
#
# Safe to run more than once: already-done steps are detected and skipped.
#
#   ./install_mise.sh       # install (if needed) + wire activation
#
# It will NOT log you out — desktop sessions keep the old shell until you do
# (the chsh trap). The script tells you when a re-login is required.
set -euo pipefail

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }       # green step
note() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }    # yellow

REPO=/etc/apt/sources.list.d/mise.list
KEYRING=/etc/apt/keyrings/mise-archive-keyring.gpg

# ---- 1. install mise from its apt repo (skip if already wired) --------------
if command -v mise >/dev/null 2>&1 && [ -f "$REPO" ]; then
  say "mise already installed from its apt repo — skipping install."
  note "$(mise --version)"
else
  say "Installing mise from its official apt repo…"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg

  sudo install -dm755 /etc/apt/keyrings
  curl -fsSL https://mise.jdx.dev/gpg-key.pub \
    | sudo gpg --dearmor -o "$KEYRING"
  sudo chmod 644 "$KEYRING"

  echo "deb [signed-by=$KEYRING arch=amd64] https://mise.jdx.dev/deb stable main" \
    | sudo tee "$REPO" >/dev/null

  sudo apt-get update
  sudo apt-get install -y mise
  note "Installed $(mise --version)"
fi

# ---- 2. wire activation into the LOGIN shell's rc (the #1 failure point) -----
# Match the login shell, NOT whatever is running this second.
login_shell="$(basename "$(getent passwd "$USER" | cut -d: -f7)")"
say "Login shell detected: $login_shell"

case "$login_shell" in
  bash) rc="$HOME/.bashrc"               ; hook='eval "$(mise activate bash)"' ;;
  zsh)  rc="$HOME/.zshrc"                ; hook='eval "$(mise activate zsh)"'  ;;
  fish) rc="$HOME/.config/fish/config.fish" ; hook='mise activate fish | source' ;;
  *)    warn "Unrecognized login shell '$login_shell'. Add activation by hand:"
        warn "  https://mise.jdx.dev/getting-started.html  (shell activation)"
        exit 0 ;;
esac

mkdir -p "$(dirname "$rc")"
if grep -qF "mise activate $login_shell" "$rc" 2>/dev/null; then
  say "Activation already present in $rc — nothing to add."
  added=no
else
  printf '\n# mise (per-project toolchains)\n%s\n' "$hook" >> "$rc"
  say "Added mise activation to $rc"
  added=yes
fi

# ---- 3. tell them what (if anything) they must do next ----------------------
running_shell="$(basename "${SHELL:-}")"
echo
if [ "$added" = yes ] || [ "$running_shell" != "$login_shell" ]; then
  warn "Activation only takes effect in a fresh login session."
  warn "Log OUT of your desktop session and back in (a new tab is not enough),"
  warn "then verify with:  mise doctor   (should report 'activated: yes')."
else
  say "Done. Open a new shell, then verify with:  mise doctor"
fi
