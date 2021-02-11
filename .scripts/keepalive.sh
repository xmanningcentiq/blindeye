#!/usr/bin/env bash
set -euo pipefail

VPN_DEFAULT_GATEWAY=""

while [ "${VPN_DEFAULT_GATEWAY}" == "" ] ; do
    VPN_DEFAULT_GATEWAY="$(grep -m 1 "nameserver" /etc/resolv.conf | awk '{ print $NF }' || true)"
    sleep 5
done

ping -i 5 "${VPN_DEFAULT_GATEWAY}" >/dev/null
