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

function narsil_useradd()
{
    msg_info '\n%s\n' "[${STATS}] Optimize useradd policy"

    # When creating a new user, login is disabled by default, so use `usermod -s /bin/bash user` to change the shell
    sed -i 's/SHELL=.*/SHELL=\/bin\/false/' /etc/default/useradd

    # After 30 days of password expiration, the account will be disabled
    sed -i 's/INACTIVE=.*/INACTIVE=30/' /etc/default/useradd

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• File Content: /etc/default/useradd"
        grep -Ev '^#|^$' /etc/default/useradd | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
