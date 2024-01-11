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

function narsil_sshdconfig()
{
    msg_info '\n%s\n' "[${STATS}] Config OpenSSH (Some configurations need to be done manually)"

    cp /etc/ssh/sshd_config /etc/ssh/sshd_config-"$(date +%Y%m%d-%s)".bak
    cp ./config/sshd_config /etc/ssh/sshd_config
    sed -i "s/.*Port.*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
    chown root:root /etc/ssh/sshd_config
    chmod 0600 /etc/ssh/sshd_config
    systemctl restart sshd.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• File Content: /etc/ssh/sshd_config"
        grep -Ev '^#|^$' /etc/ssh/sshd_config | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
