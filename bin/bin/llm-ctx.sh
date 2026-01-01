#!/usr/bin/env bash
set -euo pipefail

# llm-ctx: Build a Markdown context from files and copy to clipboard.
# - Accepts multiple files as args or lets you pick via fzf (-m) if no args.
# - Adds an HTML comment with the path relative to $PWD above each code block.
# - Guesses code fence language from filename/extension.
# - Copies the result to clipboard (pbcopy/xclip/wl-copy) or prints if none found.

die() { printf '%s\n' "$*" >&2; exit 1; }

is_text_file() {
  local f=$1
  # Consider regular files only and skip device/sockets
  [[ -f "$f" ]] || return 1
  # Heuristic: rely on 'file' when available; otherwise assume text
  if command -v file >/dev/null 2>&1; then
    file --mime "$f" 2>/dev/null | grep -qi 'text/'
  else
    return 0
  fi
}

lang_from_name() {
  local f=$1 bn ext
  bn=$(basename -- "$f")
  case "$bn" in
    Makefile|makefile) echo "make"; return;;
    Dockerfile|Containerfile) echo "dockerfile"; return;;
    .env*|*.env) echo "sh"; return;;
    .gitignore|.gitconfig) echo "conf"; return;;
    .zshrc|.bashrc|.bash_profile|.zshenv|.zprofile) echo "shell"; return;;
  esac
  ext="${bn##*.}"
  [[ "$bn" == "$ext" ]] && ext=""  # no extension
  case "$ext" in
    sh|bash|zsh|fish) echo "shell";;
    py) echo "python";;
    js) echo "javascript";;
    mjs) echo "javascript";;
    cjs) echo "javascript";;
    ts) echo "typescript";;
    tsx) echo "tsx";;
    jsx) echo "jsx";;
    json) echo "json";;
    md|markdown) echo "markdown";;
    yml|yaml) echo "yaml";;
    toml) echo "toml";;
    ini|conf|cfg) echo "ini";;
    rb) echo "ruby";;
    go) echo "go";;
    rs) echo "rust";;
    java) echo "java";;
    kt|kts) echo "kotlin";;
    swift) echo "swift";;
    c) echo "c";;
    h) echo "c";;
    cc|cpp|cxx|hpp|hh) echo "cpp";;
    cs) echo "csharp";;
    php) echo "php";;
    pl|pm) echo "perl";;
    sql) echo "sql";;
    css) echo "css";;
    scss|sass) echo "scss";;
    vue) echo "vue";;
    svelte) echo "svelte";;
    '') echo "";;
    *) echo "";;
  esac
}

rel_path() {
  # Derive a path relative to $PWD when possible, otherwise echo as-is
  local f=$1
  # Resolve to absolute
  local abs
  abs=$(cd "$(dirname -- "$f")" 2>/dev/null && pwd)/"$(basename -- "$f")"
  case "$abs" in
    "$PWD"/*) printf '%s\n' "${abs#"$PWD"/}";;
    *) printf '%s\n' "$f";;
  esac
}

pick_files_with_fzf() {
  command -v fzf >/dev/null 2>&1 || return 1
  local src preview_cmd preview_win
  if command -v rg >/dev/null 2>&1; then
    # include hidden, exclude .git
    src=$(rg --files --hidden -g '!.git' 2>/dev/null || true)
  else
    src=$(find . -type f -not -path '*/.git/*' -print 2>/dev/null | sed 's#^\./##')
  fi
  [ -n "$src" ] || return 1
  if command -v bat >/dev/null 2>&1; then
    preview_cmd='bat --style=numbers --color=always --line-range :300 {}'
  else
    preview_cmd='sed -n "1,200p" {}'
  fi
  preview_win='right:60%:wrap'
  printf '%s\n' "$src" | fzf -m --preview "$preview_cmd" --preview-window "$preview_win" | sed 's#^\./##'
}

copy_to_clipboard() {
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  else
    cat
  fi
}

usage() {
  cat <<'USAGE'
Usage: llm-ctx [FILE ...]

Builds a Markdown snippet with per-file relative path comments and code fences,
then copies it to clipboard. If no files are provided and fzf is available,
you can interactively multi-select files from the current directory with a
right-side preview of file contents.

Examples:
  llm-ctx src/index.ts package.json
  llm-ctx  # then pick files via fzf -m
USAGE
}

main() {
  local files=()
  if [ "$#" -gt 0 ]; then
    files=("$@")
  else
    mapfile -t files < <(pick_files_with_fzf || true)
    if [ "${#files[@]}" -eq 0 ]; then
      usage; exit 1
    fi
  fi

  local tmp
  tmp=$(mktemp 2>/dev/null || mktemp -t llmctx)

  local any=0
  for f in "${files[@]}"; do
    # Normalize path: allow selecting from fzf output without leading ./
    if [[ -e "$f" ]]; then :; elif [[ -e "./$f" ]]; then f="./$f"; fi
    if ! is_text_file "$f"; then
      printf 'Skipping non-text or missing: %s\n' "$f" >&2
      continue
    fi
    local rel lang fence
    rel=$(rel_path "$f")
    lang=$(lang_from_name "$f")
    if grep -q '```' -- "$f" 2>/dev/null; then fence='````'; else fence='```'; fi

    {
      printf '<!-- path: %s -->\n' "$rel"
      if [ -n "$lang" ]; then
        printf '%s%s\n' "$fence" "$lang"
      else
        printf '%s\n' "$fence"
      fi
      cat -- "$f"
      printf '\n%s\n\n' "$fence"
    } >>"$tmp"
    any=1
  done

  if [ "$any" -eq 0 ]; then
    rm -f -- "$tmp"
    die "No valid text files to copy."
  fi

  if copy_to_clipboard <"$tmp"; then
    printf 'Copied Markdown context for %d file(s).\n' "${#files[@]}"
  else
    printf 'Printed Markdown context (clipboard tool not found).\n' >&2
    cat -- "$tmp"
  fi

  rm -f -- "$tmp"
}

main "$@"
