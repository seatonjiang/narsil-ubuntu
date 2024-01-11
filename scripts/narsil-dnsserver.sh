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

function narsil_dnsserver()
{
    msg_info '\n%s\n' "[${STATS}] Change DNS Server"

    local NEW_DNSSERVER

    NEW_DNSSERVER='119.29.29.29 223.5.5.5'

    if [ "${NEW_DNSSERVER}" != "${DNS_SERVER}" ]; then
        NEW_DNSSERVER=${DNS_SERVER}
    fi

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            NEW_DNSSERVER='183.60.83.19 183.60.82.98'
        fi
    fi

    if [ -f /etc/cloud/cloud.cfg ]; then
        sed -i '/resolv_conf/d' /etc/cloud/cloud.cfg
    fi

    systemctl stop systemd-resolved.service
    systemctl disable systemd-resolved.service >/dev/null 2>&1
    systemctl mask systemd-resolved.service >/dev/null 2>&1

    find /etc/resolv.conf -delete

    for NAMESERVER in ${NEW_DNSSERVER}; do
        echo "nameserver ${NAMESERVER}" >> /etc/resolv.conf
    done

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• File Content: /etc/resolv.conf"
        grep -Ev '^#|^$' /etc/resolv.conf | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
