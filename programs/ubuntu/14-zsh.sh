#!/bin/bash

### Instalações via ZSH
## Prompt ZSH
sudo apt install zsh -y;

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";

## Instalação auto-suggestion
sudo git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions;