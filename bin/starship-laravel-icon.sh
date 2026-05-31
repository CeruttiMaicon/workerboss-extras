#!/usr/bin/env bash
# Exibe ícone se o diretório atual for um projeto Laravel.

set -euo pipefail

[[ -f artisan && -f composer.json ]] || exit 1

if command -v jq >/dev/null 2>&1; then
  jq -e '
    .require["laravel/framework"]
    // .require["laravel/lumen-framework"]
  ' composer.json >/dev/null 2>&1 || exit 1
else
  grep -qE '"laravel/framework"|"laravel/lumen-framework"' composer.json 2>/dev/null || exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
icon_file="$repo_root/icons/laravel.icon"

if [[ -f "$icon_file" ]]; then
  grep -v '^#' "$icon_file" | grep -v '^[[:space:]]*$' | head -1 | tr -d '\n\r'
else
  printf '\ue73f'
fi
