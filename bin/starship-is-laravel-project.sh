#!/usr/bin/env bash
# Sai 0 se o diretório atual for projeto Laravel/Lumen.

set -euo pipefail

[[ -f artisan && -f composer.json ]] || exit 1

if command -v jq >/dev/null 2>&1; then
  jq -e '
    .require["laravel/framework"]
    // .require["laravel/lumen-framework"]
  ' composer.json >/dev/null 2>&1
else
  grep -qE '"laravel/framework"|"laravel/lumen-framework"' composer.json 2>/dev/null
fi
