#!/bin/bash

# Instalação spaceship-prompt

sudo apt update &&

sudo apt dist-upgrade -y &&

echo "Instalando o PHP 8.1"

sudo apt install --no-install-recommends php8.1 &&

php -v &&

echo "Instalando o PHP 8.1 CLI e FPM"

sudo apt install --no-install-recommends php8.1-cli &&

sudo apt-get install -y php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath &&

echo "Instalando o Composer"

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');" &&
sudo mv composer.phar /usr/local/bin/composer