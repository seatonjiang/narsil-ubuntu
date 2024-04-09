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

function narsil_banner()
{
    msg_info '\n%s\n' "[${STATS}] Add login banner (system info, disk usage and docker status)"

    PROD_TIPS=${PROD_TIPS:-'Y'}

    # Disable motd-news
    sed -i 's/ENABLED=.*/ENABLED=0/' /etc/default/motd-news
    systemctl stop motd-news.timer
    systemctl mask motd-news.timer >/dev/null 2>&1

    # Remove defualt motd
    rm -rf /etc/update-motd.d/*

    cp ./config/banner/*-narsil-* /etc/update-motd.d/
    chmod +x /etc/update-motd.d/*-narsil-*

    if [[ ${PROD_TIPS^^} != 'Y' ]]; then
        chmod -x /etc/update-motd.d/20-aegis-footer
    fi

    msg_succ '%s\n' "Complete!"

    sleep 1

    ((STATS++))
}
