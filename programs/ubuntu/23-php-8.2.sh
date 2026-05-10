#!/bin/bash

# Instalação spaceship-prompt

sudo apt update &&

sudo apt dist-upgrade -y &&

echo "Instalando o PHP 8.2"

sudo add-apt-repository ppa:ondrej/php &&

sudo apt update &&

sudo apt install php8.2 -y &&

php --version &&

echo "Instalando o PHP 8.2 Extensions"

sudo apt-get install -y php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath &&

php -m &&

echo "Instalando o Composer"

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');" &&

sudo mv composer.phar /usr/local/bin/composer