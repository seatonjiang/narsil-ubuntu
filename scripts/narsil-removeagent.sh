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

function narsil_removeagent()
{
    msg_notic '\n%s\n\n' "Cloud Server Monitor component is being removed, please wait..."

    if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
        /usr/local/qcloud/monitor/barad/admin/uninstall.sh >/dev/null 2>&1
        /usr/local/qcloud/stargate/admin/uninstall.sh >/dev/null 2>&1
        /usr/local/qcloud/YunJing/uninst.sh >/dev/null 2>&1
        ./config/tat-agent-uninstall.sh >/dev/null 2>&1
    elif [ -n "$(wget -qO- -t1 -T2 100.100.100.200)" ]; then
        /usr/local/cloudmonitor/cloudmonitorCtl.sh stop >/dev/null 2>&1
        /usr/local/cloudmonitor/cloudmonitorCtl.sh uninstall >/dev/null 2>&1
        rm -rf /usr/local/cloudmonitor >/dev/null 2>&1
    fi

    msg_succ '%s\n\n' "All monitoring components have been uninstalled!"
}
