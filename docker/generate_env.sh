#!/bin/bash
# Copyright (C) 2021, RTE (http://www.rte-france.com)
# SPDX-License-Identifier: Apache-2.0

set -e

source_dir=$(dirname "$0")

usage()
{
    echo 'usage: generate_env.sh [-h] --interface interface --dhcp-range-begin dhcp-range-begin --dhcp-range-end dhcp-range-end'
    echo
    echo 'Arguments:'
    echo '  -h, --help          show this help message and exit'
    echo '  -i, --interface     network interface to listen for PXE'
    echo '  --dhcp-range-begin  first IP address of the DHCP range'
    echo '  --dhcp-range-end    last IP address of the DHCP range'
    echo
    echo 'See README.md for more explanations.'

}


interface=
dhcp_begin=
dhcp_end=

options=$(getopt -o hi: --long help,interface:,dhcp-range-begin:,dhcp-range-end: -- "$@")

[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}

eval set -- "$options"
while true; do
    case "$1" in
    -h|--help)
        usage
        exit 0
        ;;
    -i|--interface)
        shift
        interface="$1"
        ;;
    --dhcp-range-begin)
        shift
        dhcp_begin="$1"
        ;;
    --dhcp-range-end)
        shift
        dhcp_end="$1"
        ;;
   --)
        shift
        break
        ;;
    esac
    shift
done

if [ -z "${interface}" ] ; then
    echo "Error missing argument interface"
    usage
    exit 1
fi

if [ -z "${dhcp_begin}" ] ; then
    echo "Error missing argument dhcp-range-begin"
    usage
    exit 1
fi

if [ -z "${dhcp_end}" ] ; then
    echo "Error missing argument dhcp-range-end"
    usage
    exit 1
fi

cd "${source_dir}"

docker_gid=$(cut -d: -f3 <(getent group docker))

if [ ! -d /var/jenkins_home ] ; then
    sudo mkdir -p -v /var/jenkins_home
    sudo chown -R 1000:1000 /var/jenkins_home
fi

cat >.env << EOF
_CI_DHCP_RANGE_BEGIN=${dhcp_begin}
_CI_DHCP_RANGE_END=${dhcp_end}
_CI_DHCP_INTERFACE=${interface}
_CI_DOCKER_GID=${docker_gid}
EOF
