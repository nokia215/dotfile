

# Setting PATH for Python 3.12
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
export PATH

# Homebrew env (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Go binaries (軽くやるなら固定でもいい)
if command -v go >/dev/null 2>&1; then
  GOPATH="$(go env GOPATH)"
  if [[ -d "$GOPATH/bin" ]]; then
    path=("$GOPATH/bin" $path)
  fi
fi

# Haskell (ghcup)
[[ -f "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"
