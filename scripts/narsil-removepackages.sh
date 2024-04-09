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

function narsil_removepackages()
{
    msg_info '\n%s\n' "[${STATS}] Remove useless packages"

    REMOVE_PACKAGE="open-vm-tools popularity-contest"

    for PACKAGE in ${REMOVE_PACKAGE}; do
        apt-get purge "${PACKAGE}" -y >/dev/null 2>&1
    done

    msg_succ '%s\n' "Complete!"

    sleep 1

    ((STATS++))
}
