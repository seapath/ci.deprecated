#!/bin/sh
# Copyright (C) 2021, RTE (http://www.rte-france.com)
# SPDX-License-Identifier: Apache-2.0

echo "dhcp-range=${DHCP_RANGE_BEGIN},${DHCP_RANGE_END},48h" \
    >/etc/dnsmasq.more.conf
/usr/sbin/dnsmasq --keep-in-foreground --log-facility=-
