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

# shellcheck disable=SC2001
# shellcheck disable=SC2010
# shellcheck disable=SC2143
function narsil_fdisk()
{
    if [ -z "$(fdisk -l | grep -o "Disk /dev/.*vd[b-z]")" ];then
        msg_error '\n%s\n\n' "Error: No disk found to mount!"
        exit 1
    fi

    msg_notic '\n%s\n' "[1] Show all active disks"
    fdisk -l | grep -o "Disk /dev/.*vd[b-z]"

    msg_notic '\n%s' "[2] Choose the disk [e.g. /dev/vdb]: "
    while :; do
        read -r DISK
        if [ -z "$(echo "${DISK}" | grep '^/dev/.*vd[b-z]')" ]; then
            msg_error '%s' "Format error, please try again: "
        else
            if [ -z "$(fdisk -l | grep -o "Disk /dev/.*vd[b-z]" | grep "Disk ${DISK}")" ]; then
                msg_error '%s' "No disk found, please try again: "
            else
                fdisk_mounted
                break
            fi
        fi
    done

    msg_notic '\n%s\n' "[3] Partitioning and formatting the disk"
    fdisk_mkfs "${DISK}" >/dev/null 2>&1
    msg_succ '%s\n' "Success, the disk has been partitioned and formatted!"

    msg_notic '\n%s' "[4] Location of disk mounts [Default: /data]: "
    while :; do
        read -r MOUNT
        MOUNT=${MOUNT:-"/data"}
        if [ -z "$(echo "${MOUNT}" | grep '^/')" ]; then
            msg_error '%s' "Directory must begin with /, please try again: "
        else
            mkdir "${MOUNT}" >/dev/null 2>&1
            mount "${DISK}1" "${MOUNT}"
            break
        fi
    done
    msg_succ '%s\n' "Success, the mount is completed!"

    msg_notic '\n%s\n' "[5] Write the config to /etc/fstab and mount the device"
    if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
        SDISK=$(echo "${DISK}" | grep -o "/dev/.*vd[b-z]" | awk -F"/" '{print $(NF)}')
        SOFTLINK=$(ls -l /dev/disk/by-id | grep "${SDISK}1" | awk -F" " '{print $(NF-2)}')
        sed -i "/${SOFTLINK}/d" /etc/fstab
        echo "/dev/disk/by-id/${SOFTLINK} ${MOUNT} ext4 defaults 0 2" >> /etc/fstab
    else
        sed -i "/${DISK}1/d" /etc/fstab
        echo "${DISK}1 ${MOUNT} ext4 defaults 0 2" >> /etc/fstab
    fi
    msg_succ '%s\n' "Success, the /etc/fstab has been written!"

    msg_notic '\n%s\n' "[6] Show the amount of free disk space on the system"
    df -Th

    msg_notic '\n%s\n' "[7] Show the configuration file for /etc/fstab"
    grep -Ev '^#|^$' /etc/fstab | uniq

    printf '\n%s%s\n%s%s\n\n' "$(tput setaf 4)$(tput bold)" \
    "Done, the data disk has been mounted!" \
    "The log of this execution can be found at ${LOGFILE}" \
    "$(tput sgr0)" >&3
}

function fdisk_mounted()
{
    while mount | grep -q "${DISK}";do
        msg_error '\n%s\n' "[!] This disk has been mounted"
        mount | grep "${DISK}"
        msg_error '\n%s' "[!] Force Unloading the disk? [y/n]: "
        while :; do
        read -r UMOUNT
        if [[ ! "${UMOUNT}" =~ ^[y,n,Y,N]$ ]]; then
            msg_error '%s' "[!] Format error, please try again: "
        else
            if [ "${UMOUNT}" == 'y' ] || [ "${UMOUNT}" == 'Y' ]; then
                for i in $(mount | grep "${DISK}" | awk '{print $3}');do
                    fuser -km "$i"
                    umount "$i"
                    TEMP=$(echo "${DISK}" | sed 's;/;\\\/;g')
                    sed -i -e "/^$TEMP/d" /etc/fstab
                done
                msg_succ '%s\n' "Success, the disk is unloaded!"
            else
                exit
            fi
            break
        fi
        done
        msg_error '\n%s' "[!] Ready to format the disk? [y/n]: "
        while :; do
        read -r CHOICE
        if [[ ! "${CHOICE}" =~ ^[y,n,Y,N]$ ]]; then
            msg_error '%s' "[!] Format error, please try again: "
        else
            if [ "${CHOICE}" == 'y' ] || [ "${CHOICE}" == 'Y' ]; then
                dd if=/dev/zero of="${DISK}" bs=512 count=1 >/dev/null 2>&1
                sync
                msg_succ '%s\n' "Success, the disk has been formatted!"
            else
                exit
            fi
            break
        fi
        done
    done
}

function fdisk_mkfs()
{
    fdisk "$1" << EOF
n
p
1


wq
EOF

    sleep 3
    partprobe
    mkfs -t ext4 "${1}1"
}
