#!/usr/bin/env bash
set -euo pipefail

for v in 'VPN_SERVER' 'VPN_DOMAIN' 'VPN_USER' 'VPN_PASS' ; do
    VARTEST="${v}"
    if [ -z ${!VARTEST:-} ] ; then
        if [[ "${v}" =~ _PASS$ ]] ; then
            echo -n "${v}: "
            read -r -s ${v?}
            echo ""
        else
            read -r -p "${v}: " ${v?}
        fi
    fi
done

AUTH_KEY="${VPN_SSH_KEY:-${HOME}/.ssh/id_rsa.pub}"
VPROXY_SSH_PORT=$((${PROXY_PORT_OFFSET:-20000} + 22))
VPROXY_SQUID_PORT=$((${PROXY_PORT_OFFSET:-20000} + 3128))

if [ ! -f "${AUTH_KEY}" ] ; then
    echo "Cannot find ${AUTH_KEY}. Please set VPN_SSH_KEY."
    exit 1
else
    TMP_AUTH_KEY="$(mktemp /tmp/VPN_AUTH_KEY.XXXXXXXXX)"
    cp "${AUTH_KEY}" "${TMP_AUTH_KEY}"
    chmod 0600 "${TMP_AUTH_KEY}"
fi

docker build -t blindeye:latest .
docker run -d \
    -e "VPN_USER=${VPN_USER}" \
    -e "VPN_PASS=${VPN_PASS}" \
    -e "VPN_DOMAIN=${VPN_DOMAIN}" \
    -e "VPN_SERVER=${VPN_SERVER}" \
    -v "${TMP_AUTH_KEY}:/home/null/.ssh/authorized_keys" \
    -p "127.0.0.1:${VPROXY_SSH_PORT}:22" \
    -p "127.0.0.1:${VPROXY_SQUID_PORT}:3128" \
    --privileged \
    --name "blindeye-${VPN_USER}" \
    --rm blindeye:latest
