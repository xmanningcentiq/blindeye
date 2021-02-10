#!/usr/bin/env bash
set -euo pipefail

for v in 'VPN_SERVER' 'VPN_DOMAIN' 'VPN_USER' 'VPN_PASS' ; do
    if [[ "${v}" =~ _PASS$ ]] ; then
        echo -n "${v}: "
        read -s ${v}
        echo ""
    else
        read -r -p "${v}: " ${v}
    fi
done

docker build -t blindeye:latest .
docker run -d \
    -e "VPN_USER=${VPN_USER}" \
    -e "VPN_PASS=${VPN_PASS}" \
    -e "VPN_DOMAIN=${VPN_DOMAIN}" \
    -e "VPN_SERVER=${VPN_SERVER}" \
    -p 127.0.0.1:30022:22 \
    -p 127.0.0.1:30053:53 \
    -p 127.0.0.1:33128:3128 \
    --privileged \
    --name "blindeye-${VPN_USER}" \
    --rm blindeye:latest
