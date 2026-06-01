#!/usr/bin/env bash
# Sai 0 se o Node deve aparecer no prompt: projeto Node e não Laravel.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Laravel: nunca mostrar Node
if "$script_dir/starship-is-laravel-project.sh" 2>/dev/null; then
  exit 1
fi

# Mesmos gatilhos do módulo nativo [nodejs] (só no diretório atual)
if [[ -f package.json || -f .nvmrc || -f .node-version || -d node_modules ]]; then
  exit 0
fi

if find . -maxdepth 1 -type f \( \
  -name '*.js' -o -name '*.mjs' -o -name '*.cjs' \
  -o -name '*.ts' -o -name '*.mts' -o -name '*.cts' \
\) -print -quit 2>/dev/null | grep -q .; then
  exit 0
fi

exit 1
