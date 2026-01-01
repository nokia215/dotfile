# Repository Guidelines

## Project Structure & Module Organization
- Root: version-controlled dotfiles and configuration snippets used across machines.
- `.bin/`: small, single-purpose executables intended to be on your `PATH`.
- Examples: `.bin/git-clean`, `.bin/dot-sync` (short, focused utilities).

## Build, Test, and Development Commands
- Run locally: `./.bin/<script> [args]` (ensure executable bit set).
- Add to PATH: `export PATH="$HOME/dotfiles/.bin:$PATH"` (put in your shell RC).
- Lint scripts (if installed): `shellcheck .bin/*` (static analysis for shells).
- Format scripts (if installed): `shfmt -w .bin` (consistent style across files).

## Coding Style & Naming Conventions
- Language: prefer POSIX `sh`; use `bash` only when needed and document it.
- Shebangs: `#!/usr/bin/env sh` (or `bash` if required) at line 1.
- Safety: add `set -eu` (and `-o pipefail` for bash) near the top.
- Indentation: 2 spaces; avoid tabs. Keep lines under ~100 chars.
- Executables: kebab-case, no file extension (e.g., `git-clean`).
- Functions/vars: lowercase_with_underscores; constants in UPPER_SNAKE_CASE.

## Testing Guidelines
- Self-test: provide `--help` that demonstrates usage and exits 0.
- Optional `bats`: mirror names under `test/` (e.g., `test/git-clean.bats`).
- Quick check before pushing: `shellcheck`, then `./.bin/<script> --help`.

## Commit & Pull Request Guidelines
- Messages: imperative, present-tense; include scope (e.g., `bin:`, `zsh:`, `vim:`).
- Conventional Commits welcome (e.g., `feat(bin): add git-clean`).
- PRs: include purpose, usage examples, platform assumptions, and linked issues.

## Security & Configuration Tips
- Do not commit secrets; prefer local overrides and placeholders like `<TOKEN>`.
- For installers or mutating scripts, prompt before destructive actions; support `--dry-run`.
- Keep scripts idempotent and safe to re-run; detect OS with `uname` when needed.

