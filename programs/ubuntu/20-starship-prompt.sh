#!/bin/bash

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -euo pipefail

# Instala o Starship e liga ~/.config/starship.toml ao ficheiro versionado neste repo.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STARSHIP_SRC="$REPO_ROOT/starship.toml"

if [[ -n "${SUDO_USER:-}" ]]; then
  TARGET_USER="$SUDO_USER"
  TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
else
  TARGET_USER="${USER:-$(whoami)}"
  TARGET_HOME="$HOME"
fi

STARSHIP_DEST="$TARGET_HOME/.config/starship.toml"

if [[ ! -f "$STARSHIP_SRC" ]]; then
  echo "Erro: starship.toml não encontrado em $STARSHIP_SRC" >&2
  exit 1
fi

echo "Instalando Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

mkdir -p "$TARGET_HOME/.config"

if [[ -e "$STARSHIP_DEST" && ! -L "$STARSHIP_DEST" ]]; then
  if [[ -s "$STARSHIP_DEST" ]]; then
    backup="$STARSHIP_DEST.bak.$(date +%Y%m%d%H%M%S)"
    cp -a "$STARSHIP_DEST" "$backup"
    echo "Backup do config anterior: $backup"
  fi
  rm -f "$STARSHIP_DEST"
fi

ln -sfn "$STARSHIP_SRC" "$STARSHIP_DEST"
chown -h "$TARGET_USER:$TARGET_USER" "$STARSHIP_DEST" 2>/dev/null || true

ZSHRC="$TARGET_HOME/.zshrc"
STARSHIP_INIT_BLOCK='eval "$(starship init zsh)"'
STARSHIP_ENV_START="# >>> starship prompt >>>"
STARSHIP_ENV_END="# <<< starship prompt <<<"
STARSHIP_ENV_BLOCK="export STARSHIP_CONFIG=\"$STARSHIP_DEST\"\nexport ZSHMAP_EXTRAS_DIR=\"$REPO_ROOT\"\nexport ZLE_RPROMPT_INDENT=0"

touch "$ZSHRC"

if grep -F "$STARSHIP_ENV_START" "$ZSHRC" >/dev/null 2>&1; then
  tmp_zshrc="$(mktemp)"
  awk -v start="$STARSHIP_ENV_START" -v end="$STARSHIP_ENV_END" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$ZSHRC" > "$tmp_zshrc"
  mv "$tmp_zshrc" "$ZSHRC"
fi

{
  echo ""
  echo "$STARSHIP_ENV_START"
  printf '%b\n' "$STARSHIP_ENV_BLOCK"
  echo "$STARSHIP_ENV_END"
} >> "$ZSHRC"
echo "Atualizadas variáveis do Starship em $ZSHRC"

if ! rg -F -x "$STARSHIP_INIT_BLOCK" "$ZSHRC" >/dev/null 2>&1; then
  {
    echo ""
    echo "# Starship prompt"
    echo "$STARSHIP_INIT_BLOCK"
  } >> "$ZSHRC"
  echo "Adicionado Starship init em $ZSHRC"
fi

if command -v starship >/dev/null 2>&1; then
  echo "Binário Starship encontrado em: $(command -v starship)"
else
  echo "Aviso: comando 'starship' não encontrado no PATH atual." >&2
  echo "Abra um novo terminal (ou faça logout/login) para atualizar o PATH." >&2
fi

echo "Starship instalado."
echo "Config: $STARSHIP_DEST -> $STARSHIP_SRC"
echo "Reabra o terminal para carregar o tema."
