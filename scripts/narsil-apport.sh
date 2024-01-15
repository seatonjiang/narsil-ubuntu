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

function narsil_apport()
{
    msg_info '\n%s\n' "[${STATS}] Disable Apport service"

    if [ -f /etc/default/apport ]; then
        sed -i 's/enabled=.*/enabled=0/' /etc/default/apport
        systemctl stop apport.service
        systemctl mask apport.service >/dev/null 2>&1

        if [[ ${VERIFY^^} == 'Y' ]]; then
            msg_notic '\n%s\n' "• Service Status"
            systemctl status apport.service --no-pager
            msg_notic '\n%s\n' "• File Content: /etc/default/apport"
            grep enabled /etc/default/apport
        else
            msg_succ '%s\n' "Complete!"
        fi
    else
        msg_succ '%s\n' "No such service, skip!"
    fi

    sleep 1

    ((STATS++))
}
