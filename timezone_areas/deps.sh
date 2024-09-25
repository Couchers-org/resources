#!/bin/bash

# works on ubuntu 22.04, tested on AWS
# installs docker, docker-compose, aws-cli

set -e

# update, upgrade
sudo apt -y update
sudo apt -y dist-upgrade

# install docker
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $(whoami) # make me able to use docker without sudo

sudo apt install -y gdal-bin unzip
