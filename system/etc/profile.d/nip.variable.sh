#!/bin/bash

if [ -z "${NIP}" ]; then
    sudo bash -c 'echo "NIP="$(nip.sh) >> /etc/environment' 2> /dev/null
fi;