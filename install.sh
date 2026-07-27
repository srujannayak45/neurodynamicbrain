#!/usr/bin/env bash
# Idempotent installer — symlinks the Claude portable artefacts from this
# repo into ~/.claude/. Backs up any pre-existing real files first.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/.predotfiles-backup-$TS"

mkdir -p "$CLAUDE_DIR"

backup_and_link() {
  local name="$1"
  local src="$DOTFILES_DIR/claude/$name"
  local dst="$CLAUDE_DIR/$name"

  if [ ! -e "$src" ]; then
    echo "  skip: $src missing in this repo"
    return
  fi

  # Already the right symlink? Nothing to do.
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok:   $dst already linked"
    return
  fi

  # Existing path — back it up (real file/dir OR wrong symlink).
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$name"
    echo "  back: $dst -> $BACKUP_DIR/$name"
  fi

  ln -s "$src" "$dst"
  echo "  link: $dst -> $src"
}

echo "Installing Claude dotfiles symlinks from: $DOTFILES_DIR"
for n in CLAUDE.md brain skills; do
  backup_and_link "$n"
done

if [ -d "$BACKUP_DIR" ]; then
  echo
  echo "Backed-up originals: $BACKUP_DIR"
fi

# Post-install: make effector code executable (the R-units' arms — see brain cell B-060)
# and validate the brain. references/ + new skills ride along inside the brain/ and
# skills/ dir symlinks, so no extra link entries are needed.
echo
echo "Post-install:"
BRAIN_SH="$CLAUDE_DIR/brain/brain.sh"
if [ -f "$BRAIN_SH" ]; then
  chmod +x "$BRAIN_SH"
  # skill effector scripts (skills/<name>/*.sh and shared skills/_lib/*.sh)
  find "$CLAUDE_DIR/skills" -type f -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
  echo "  exec: brain.sh + skill *.sh scripts"
  echo "  brain doctor:"
  if "$BRAIN_SH" doctor >/dev/null 2>&1; then
    echo "    PASS — brain is consistent ($("$BRAIN_SH" stats 2>/dev/null | awk '/^cells:/{print $2}') cells)."
  else
    echo "    FAIL — run '$BRAIN_SH doctor' to see the issues."
  fi
else
  echo "  (brain.sh not found — skipping brain validation)"
fi
echo "Done."