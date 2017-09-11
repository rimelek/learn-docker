#!/bin/bash

DOMAIN=${1}
PREFIX=${DOMAIN}

if [ ! -z "${PREFIX}" ]; then
    PREFIX=${PREFIX}.
fi

IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

echo ${PREFIX}${IP}.xip.io