#!/bin/sh

for v in 'VPN_USER' 'VPN_PASS' 'VPN_DOMAIN' 'VPN_SERVER'; do
    if test -z $(eval "echo \$$v"); then
        echo "Missing env variable $v" >&2
        exit 1
    fi
done

for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
    iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

delayed_start()
{
    while test $(ps -ef | grep -v grep | grep -c nxMonitor) -eq 0 ; do
        sleep 1
    done
    dnsmasq
    squid
    dropbear -s -m -R
    /root/keepalive.sh
}

delayed_start &

echo "------------ VPN Starts ------------"
/root/launch.expect
echo "------------ VPN exited ------------"
