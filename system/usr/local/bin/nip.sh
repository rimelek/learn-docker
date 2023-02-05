#!/bin/bash

# set -eu -o pipefail

DOMAIN=${1}

function get_ip() {
  local iface
  local ip

  if command -v ip &>/dev/null; then
    >&2 echo "ip command detected..."
    ip route get 8.8.8.8 \
      | grep -o 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' \
      | awk '{print $NF}'
  elif command -v ipconfig &>/dev/null; then
    >&2 echo "ipconfig command detected..."
    for iface in $(ipconfig getiflist | tr ' ' '\n' | sort); do
      ip="$(ipconfig getifaddr "$iface")"
      if [[ "$(echo "$ip" | cut -d '.' -f1-2)" == "169.254" ]]; then
        continue
      fi
      if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
      fi
    done

  else
    >&2 echo "Cannot determine IP address. ip or ipconfig commands are not found."
    return 1
  fi
}

PREFIX=${DOMAIN}
if [[ -n "${PREFIX}" ]]; then
    PREFIX=${PREFIX}.
fi

IP=$(get_ip)

echo ${PREFIX}${IP}.nip.io