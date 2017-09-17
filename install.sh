#!/bin/bash

DOCKER_VERSION=17.06.2~ce-0~ubuntu
DOCKER_COMPOSE_VERSION=1.16.1

# upgrade

apt-get update
apt-get dist-upgrade -y

# Repository

apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
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