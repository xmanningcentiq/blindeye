#!/usr/bin/env bash
set -euo pipefail

VPN_DEFAULT_GATEWAY=""

while [ "${VPN_DEFAULT_GATEWAY}" == "" ] ; do
    _GWS="$(grep -m 1 "nameserver" /etc/resolv.conf || true)"
    _GWADDR="$(echo "${_GWS}" | awk '{ print $NF }' || true)"
    VPN_DEFAULT_GATEWAY="${_GWADDR}"
    sleep 5
done

ping -i 5 "${VPN_DEFAULT_GATEWAY}" >/dev/null
