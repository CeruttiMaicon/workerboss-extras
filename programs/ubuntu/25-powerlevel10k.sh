#!/bin/bash

# Atualiza o sistema e instala o curl
sudo apt update && sudo apt install curl -y

# Instala o zsh
sudo apt install zsh -y

# Instala o Oh My Zsh se ainda não estiver instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Instala o Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Atualiza a configuração do tema no ~/.zshrc
ZSHRC="$HOME/.zshrc"
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
    # Se a linha 'ZSH_THEME=' já existir, atualize-a
    sed -i.bak '/^ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC"
else
    # Se a linha 'ZSH_THEME=' não existir, adicione-a
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
fi

echo "Powerlevel10k instalado e configurado com sucesso."