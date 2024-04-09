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

function narsil_ntpserver()
{
    msg_info '\n%s\n' "[${STATS}] Change NTP Server"

    VERIFY=${VERIFY:-'Y'}
    METADATA=${METADATA:-'Y'}
    NTP_SERVER=${NTP_SERVER:-'ntp1.tencent.com ntp2.tencent.com ntp3.tencent.com ntp4.tencent.com ntp5.tencent.com'}

    systemctl stop systemd-timesyncd
    systemctl mask systemd-timesyncd >/dev/null 2>&1

    apt-get purge ntp -y >/dev/null 2>&1

    apt-get install chrony -y >/dev/null 2>&1

    cp ./config/chrony.conf /etc/chrony/chrony.conf

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            NTP_SERVER='time1.tencentyun.com time2.tencentyun.com time3.tencentyun.com time4.tencentyun.com time5.tencentyun.com'
        elif [ -n "$(wget -qO- -t1 -T2 100.100.100.200)" ]; then
            NTP_SERVER='ntp7.cloud.aliyuncs.com ntp8.cloud.aliyuncs.com ntp9.cloud.aliyuncs.com ntp10.cloud.aliyuncs.com ntp11.cloud.aliyuncs.com'
        fi
    fi

    for SERVER in ${NTP_SERVER}; do
        echo "server ${SERVER} iburst" >> /etc/chrony/chrony.conf
    done

    systemctl restart chronyd.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• NTP synchronization status"
        chronyc tracking
        msg_notic '\n%s\n' "• NTP pools"
        chronyc sources
        msg_notic '\n%s\n' "• File Content: /etc/chrony/chrony.conf"
        grep -Ev '^#|^$' /etc/chrony/chrony.conf | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
