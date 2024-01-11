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

function narsil_timeout()
{
    msg_info '\n%s\n' "[${STATS}] Set system timeout to auto logout"

    if ! grep -nqri "TMOUT" /etc/profile.d/; then
        echo "export TMOUT=180" > /etc/profile.d/auto-logout.sh
        echo "readonly TMOUT" >> /etc/profile.d/auto-logout.sh
        chmod 0644 /etc/profile.d/auto-logout.sh

        if [[ ${VERIFY^^} == 'Y' ]]; then
            msg_notic '\n%s\n' "• File Content: /etc/profile.d/"
            grep -nri "TMOUT" /etc/profile.d/
        else
            msg_succ '%s\n' "Complete!"
        fi
    else
        msg_succ '%s\n' "Skip, this configuration already exists!"
    fi

    sleep 1

    ((STATS++))
}
