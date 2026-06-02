#!/usr/bin/env bash
# Mostra um ícone sempre, indicando se commit.gpgsign está ligado, desligado ou ausente.

set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 1

signing_raw="$(git config --get commit.gpgsign 2>/dev/null || true)"

if [[ -z "$signing_raw" ]]; then
  printf '🔓?'
  exit 0
fi

if git config --bool --get commit.gpgsign >/dev/null 2>&1 && [[ "$(git config --bool --get commit.gpgsign 2>/dev/null)" == "true" ]]; then
  printf '🔏'
else
  printf '🔓'
fi

exit 0
