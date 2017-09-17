#!/bin/bash

if [ -z "${XIP}" ]; then
    sudo bash -c 'echo "XIP="$(xip) >> /etc/environment' 2> /dev/null
fi;