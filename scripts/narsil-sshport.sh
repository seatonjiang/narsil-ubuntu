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

function narsil_sshport()
{
    if [ ! -e "/etc/ssh/sshd_config" ];then
        msg_error '\n%s\n' "Error: Can't find sshd config file!"
        exit 1
    fi

    # Install netstat
    dnf install -y net-tools >/dev/null 2>&1

    local OLD_SSH_PORT

    OLD_SSH_PORT=$( grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1 )

    if [ -z "${OLD_SSH_PORT}" ];then
        OLD_SSH_PORT='22'
    fi

    msg_notic '\n%s' "[1/2] Please enter SSH port (Range of 10000 to 65535, current is ${OLD_SSH_PORT}): "

    while :; do
        read -r NEW_SSH_PORT
        NPTSTATUS=$( netstat -lnp | grep "${NEW_SSH_PORT}" )
        if [ -n "${NPTSTATUS}" ];then
            msg_error '%s' "The port is already occupied, Please try again (Range of 10000 to 65535): "
        elif [ "${NEW_SSH_PORT}" -lt 10000 ] || [ "${NEW_SSH_PORT}" -gt 65535 ];then
            msg_error '%s' "Please try again (Range of 10000 to 65535): "
        else
            break
        fi
    done

    if [[ "${OLD_SSH_PORT}" != "22" ]]; then
        sed -i "s@^Port.*@Port ${NEW_SSH_PORT}@" /etc/ssh/sshd_config
    else
        sed -i "s@^#Port.*@&\nPort ${NEW_SSH_PORT}@" /etc/ssh/sshd_config
        sed -i "s@^Port.*@Port ${NEW_SSH_PORT}@" /etc/ssh/sshd_config
    fi

    msg_succ '%s\n' "Success, the SSH port modification completed!"
    msg_notic '\n%s\n' "[2/2] Restart the service to take effect"
    systemctl restart sshd.service >/dev/null 2>&1
    msg_succ '%s\n\n' "Success, don't forget to enable [TCP:${NEW_SSH_PORT}] for the security group!"
}
