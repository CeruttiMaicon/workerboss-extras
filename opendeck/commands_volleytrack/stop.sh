#!/usr/bin/env bash

COMMAND="stop"

# Abre o Warp (via desktop entry)
gtk-launch warp &

# Aguarda a janela existir
sleep 1.2

# Garante foco na janela do Warp
wmctrl -xa warp || true
sleep 0.3

# Nova aba
xdotool key ctrl+shift+t
sleep 0.4

# Digita o comando (sem pressa)
xdotool type --delay 5 "$COMMAND"
xdotool key Return