#!/usr/bin/env bash
#
# Narsil (Ubuntu) - Security hardening tool
# Seaton Jiang <hi@seatonjiang.com>
#
# The latest version of Narsil can be found at:
# https://github.com/seatonjiang/narsil-ubuntu
#
# Licensed under the MIT license:
# https://github.com/seatonjiang/narsil-ubuntu/blob/main/LICENSE
#

function narsil_tcpbbr()
{
    msg_info '\n%s\n' "[${STATS}] Enable TCP BBR"

    VERIFY=${VERIFY:-'Y'}

    if ! sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr; then
        {
            echo -e '\n# Controls the use of TCP BBR'
            echo "net.core.default_qdisc=fq"
            echo "net.ipv4.tcp_congestion_control=bbr"
        } >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1
    fi

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• Kernel Parameter"
        sysctl net.ipv4.tcp_available_congestion_control
        msg_notic '\n%s\n' "• Kernel Modules"
        lsmod | grep bbr
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
