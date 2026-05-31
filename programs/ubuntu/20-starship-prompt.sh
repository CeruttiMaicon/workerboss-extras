#!/bin/bash

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

echo "Starship instalado."
echo "Config: $STARSHIP_DEST -> $STARSHIP_SRC"
echo "Reinicie o terminal ou execute: eval \"\$(starship init zsh)\""
