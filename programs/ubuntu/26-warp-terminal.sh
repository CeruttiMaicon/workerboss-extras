#!/bin/bash

# Definir a URL do pacote .deb
DEB_URL="https://releases.warp.dev/stable/v0.2024.07.23.08.02.stable_01/warp-terminal_0.2024.07.23.08.02.stable.01_amd64.deb"

# Definir o nome do arquivo .deb
DEB_FILE="warp-terminal_0.2024.07.23.08.02.stable.01_amd64.deb"

# Baixar o pacote .deb
curl -L -o $DEB_FILE $DEB_URL

# Instalar o pacote .deb
sudo dpkg -i $DEB_FILE

# Corrigir dependências faltantes, se houver
sudo apt-get install -f

# Verificar se o Warp foi instalado corretamente
warp-terminal --version