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

function narsil_hostname()
{
    HOSTNAME=${HOSTNAME:-'Ubuntu'}
    METADATA=${METADATA:-'Y'}

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            HOSTNAME=$(wget -qO- -t1 -T2 metadata.tencentyun.com/latest/meta-data/instance-name)
          elif [ -n "$(wget -qO- -t1 -T2 100.100.100.200)" ]; then
            HOSTNAME=$(wget -qO- -t1 -T2 100.100.100.200/latest/meta-data/instance/instance-name)
        fi
    fi

    if [ "${HOSTNAME}" == "未命名" ]; then
        HOSTNAME='Ubuntu'
    fi

    msg_notic '\n%s' "Please enter new hostname [Default: ${HOSTNAME}]: "

    while :; do
        read -r GET_HOSTNAME
        NEW_HOSTNAME=${GET_HOSTNAME:-"${HOSTNAME}"}
        break
    done

    OLD_HOSTNAME=$(hostname)

    hostnamectl set-hostname --static "${NEW_HOSTNAME}"
    sed -i "s@${OLD_HOSTNAME}@${NEW_HOSTNAME}@g" /etc/hosts

    if [ -f /etc/cloud/cloud.cfg ]; then
        sed -i '/update_hostname/d' /etc/cloud/cloud.cfg
    fi

    msg_succ '\n%s\n\n' "Hostname has been changed successfully!"

    exit 0
}
