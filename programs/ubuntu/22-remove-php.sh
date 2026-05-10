#!/bin/bash

echo "Removendo o dependências da instalação PHP (independênte da versão)"

sudo apt-get remove --purge php* &&
sudo apt-get autoremove

echo "PHP Removido com sucesso!"