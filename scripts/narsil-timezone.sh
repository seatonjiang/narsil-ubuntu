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

function narsil_timezone()
{
    msg_info '\n%s\n' "[${STATS}] Config system time zone"

    timedatectl set-timezone "${TIME_ZONE}"
    timedatectl set-local-rtc 0

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• Check time zone"
        ls -la /etc/localtime
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
