# ~/.zshrc

# --- p10k instant prompt (keep near top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- oh-my-zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# update policy: you chose auto
zstyle ':omz:update' mode auto

plugins=(
  git
  sudo
  colored-man-pages
  command-not-found

  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search

  fzf
  fzf-tab
  zoxide
)

source "$ZSH/oh-my-zsh.sh"

# --- aliases ---
alias ls="eza"

# --- p10k ---
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# --- direnv ---
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# --- local overrides (NOT in git) ---
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"