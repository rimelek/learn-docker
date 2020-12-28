#!/bin/bash

DOMAIN=${1}
PREFIX=${DOMAIN}

if [ ! -z "${PREFIX}" ]; then
    PREFIX=${PREFIX}.
fi

IP=$(ip route get 8.8.8.8 | grep -o 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $NF}')

echo ${PREFIX}${IP}.xip.io