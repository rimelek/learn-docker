#!/bin/bash

DOCKER_VERSION=5:20.10.1~3-0~ubuntu-focal
DOCKER_COMPOSE_VERSION=1.27.4

# Repository
apt update
apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Docker CE

apt-get update

apt-get install -y --no-install-recommends docker-ce=${DOCKER_VERSION}

curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# LXD upgrade

add-apt-repository -y ppa:ubuntu-lxc/lxd-stable

apt-get update

apt-get dist-upgrade -y