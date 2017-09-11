#!/bin/bash

HOSTROW=$(hostname | xargs getent hosts)

if [ -z "${HOSTROW}" ]; then
   sudo bash -c 'echo "127.0.1.1 "${HOSTNAME} >> /etc/hosts' 2> /dev/null
fi;
