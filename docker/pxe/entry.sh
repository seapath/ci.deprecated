#!/bin/sh
# Copyright (C) 2021, RTE (http://www.rte-france.com)
# SPDX-License-Identifier: Apache-2.0

cat > /etc/dnsmasq.more.conf << EOF
dhcp-range=${DHCP_RANGE_BEGIN},${DHCP_RANGE_END},48h
interface=${DHCP_BIND_INTERFACE}
EOF
/usr/sbin/dnsmasq --keep-in-foreground --log-facility=-
