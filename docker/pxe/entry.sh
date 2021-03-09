#!/bin/sh
echo "dhcp-range=${DHCP_RANGE_BEGIN},${DHCP_RANGE_END},48h" \
    >/etc/dnsmasq.more.conf
/usr/sbin/dnsmasq --keep-in-foreground --log-facility=-
