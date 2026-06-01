#!/usr/bin/env bash
# Exibe ícone se o diretório atual for um projeto Laravel.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$script_dir/starship-is-laravel-project.sh" || exit 1

repo_root="$(cd "$script_dir/.." && pwd)"
icon_file="$repo_root/icons/laravel.icon"

if [[ -f "$icon_file" ]]; then
  grep -v '^#' "$icon_file" | grep -v '^[[:space:]]*$' | head -1 | tr -d '\n\r'
else
  printf '\ue73f'
fi
