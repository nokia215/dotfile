# ~/.zshenv
# Keep this file minimal: it runs for ALL zsh invocations.

# Rust (if you really need it globally)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export EDITOR=nvim
export VISUAL="$EDITOR"

# Deduplicate PATH entries
typeset -U path PATH

# Personal bins
if [[ -d "$HOME/bin" ]]; then
  path=("$HOME/bin" $path)
fi

if [[ -d "$HOME/.local/bin" ]]; then
  path=("$HOME/.local/bin" $path)
fi