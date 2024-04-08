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

function narsil_clearlogs()
{
    msg_notic '\n%s\n\n' "Clearing all syslog files, please wait..."

    find /var/log -type f -regex '.*\.[0-9]$' -delete
    find /var/log -type f -regex '.*-[0-9]*$' -delete
    find /var/log -type f -regex '.*\.gz$' -delete

    while IFS= read -r -d '' logfiles
    do
        true > "${logfiles}"
    done < <(find /var/log/ -type f ! -name 'narsil-*' -print0)

    # /var/log/journal/
    rm -rf /var/log/journal/*
    systemctl restart systemd-journald.service

    # /var/cache/fontconfig/
    if [ -d /var/cache/fontconfig ]; then
        find /var/cache/fontconfig -type f -delete
    fi

    # /var/backups/
    find /var/backups -type f -delete

    apt-get autoclean -y >/dev/null 2>&1
    apt-get autoremove -y >/dev/null 2>&1

    history -c
    history -w

    msg_succ '%s\n\n' "All syslog files have been cleaned!"
}
