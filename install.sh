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

# Do not forget to remove older LXC versions installed with APT
snap install lxd --channel 4.9/stable
lxd init
# Q1: Would you like to use LXD clustering? (yes/no) [default=no]:
# A1: no
# Q2: Do you want to configure a new storage pool? (yes/no) [default=yes]:
# A2: yes
# Q3: Name of the new storage pool [default=default]
# A3: default
# Q4: Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
# A4: zfs
# Q5: Create a new ZFS pool? (yes/no) [default=yes]:
# A5: yes
# Q6: Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]:
# A6: no
# Q7: Size in GB of the new loop device (1GB minimum) [default=25GB]:
# A7: Choose a suitable size for you depending on how much space you have.
# Q8: Would you like to connect to a MAAS server? (yes/no) [default=no]:
# A8: no
# Q9: Would you like to create a new local network bridge? (yes/no) [default=yes]:
# A9: yes
# Q10: What should the new bridge be called? [default=lxdbr0]:
# A10: lxdbr0
# Q11: What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
# A11: auto
# Q12: What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
# A13: none
# Q14: Would you like LXD to be available over the network? (yes/no) [default=no]:
# A14: no
# Q15: Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
# A15: no
# Q16: Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
# A16: Optional. Type "yes" if you want to see the result of the initialization.

# config:
#   images.auto_update_interval: "0"
# networks:
# - config:
#     ipv4.address: auto
#     ipv6.address: none
#   description: ""
#   name: lxdbr0
#   type: ""
#   project: default
# storage_pools:
# - config:
#     size: 25GB
#   description: ""
#   name: default
#   driver: zfs
# profiles:
# - config: {}
#   description: ""
#   devices:
#     eth0:
#       name: eth0
#       network: lxdbr0
#       type: nic
#     root:
#       path: /
#       pool: default
#       type: disk
#   name: default
# cluster: null