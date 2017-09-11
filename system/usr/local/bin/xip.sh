#!/bin/bash

DOMAIN=${1:?First argument is required}

IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

echo ${DOMAIN}.${IP}.xip.io