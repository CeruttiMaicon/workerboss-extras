#!/bin/bash

## Instalação docker compose v2

sudo apt update &&

sudo apt install docker-compose-plugin &&

docker compose version &&

sudo usermod -aG docker $USER &&

newgrp docker