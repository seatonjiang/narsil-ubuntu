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

function narsil_ctrlaltdel()
{
    msg_info '\n%s\n' "[${STATS}] Disable Ctrl-Alt-Delete target"

    systemctl stop ctrl-alt-del.target
    systemctl mask -f ctrl-alt-del.target >/dev/null 2>&1

    sed -i 's/^#CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' /etc/systemd/system.conf

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• Service Status"
        systemctl status ctrl-alt-del.target --no-pager
        msg_notic '\n%s\n' "• File Content: /etc/systemd/system.conf"
        grep CtrlAltDelBurstAction /etc/systemd/system.conf
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
