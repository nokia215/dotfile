#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it first:"
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

# 2) Brew bundle
brew bundle --file "$DOTFILES_DIR/Brewfile"

# 3) stow
if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found (should be in Brewfile)."
  exit 1
fi

cd "$DOTFILES_DIR"
stow -t "$HOME" zsh

# Cleanup any previous incorrect installs
stow -D -t "$HOME/bin" bin || true
stow -D -t "$HOME" bin || true

# Ensure ~/bin exists and stow with standard layout (bin/bin/* -> ~/bin/*)
mkdir -p "$HOME/bin"
stow -t "$HOME" bin

echo "Done. Open a new shell."
