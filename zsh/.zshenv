# ~/.zshenv
# Keep this file minimal: it runs for ALL zsh invocations.

export EDITOR=nvim
export VISUAL="$EDITOR"

# Deduplicate PATH entries
typeset -U path PATH

# Personal bins
# Prefer XDG-style user binaries.
if [[ -d "$HOME/.local/bin" ]]; then
  path=("$HOME/.local/bin" $path)
fi

# Legacy: keep only if you intentionally use ~/bin
if [[ -d "$HOME/bin" ]]; then
  path=("$HOME/bin" $path)
fi
