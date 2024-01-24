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

function narsil_docker()
{
    msg_notic '\n%s\n\n' "Docker Engine is installing, please wait..."

    local DOCKER_CE
    local DOCKER_HUB

    DOCKER_CE='https://mirrors.cloud.tencent.com/docker-ce'
    DOCKER_HUB='https://hub.c.163.com'

    if [ "${DOCKER_CE}" != "${DOCKER_CE_REPO}" ]; then
        DOCKER_CE=${DOCKER_CE_REPO}
    fi

    if [ "${DOCKER_HUB}" != "${DOCKER_HUB_MIRRORS}" ]; then
        DOCKER_HUB=${DOCKER_HUB_MIRRORS}
    fi

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            DOCKER_HUB='https://mirror.ccs.tencentyun.com'
        fi
    fi

    # Uninstall Docker Engine
    local PKG

    for PKG in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        apt-get remove "{$PKG}" -y >/dev/null 2>&1;
    done

    apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y >/dev/null 2>&1

    # Install Dependencies
    apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
    curl -fsSL "${DOCKER_CE}"/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

    # Add Software Repositories
    echo "deb [arch=$(dpkg --print-architecture)] ${DOCKER_CE}/linux/ubuntu $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list

    # Install Docker
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    mkdir -p /etc/docker

    {
        echo '{'
        echo '  "registry-mirrors": ['
        echo "    \"${DOCKER_HUB}\""
        echo '  ],'
        echo '  "log-driver": "json-file",'
        echo '  "log-opts": {'
        echo '    "max-size": "50m",'
        echo '    "max-file": "7"'
        echo '  }'
        echo '}'
    } > /etc/docker/daemon.json

    systemctl restart docker.service
    systemctl enable docker.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• Docker version"
        docker version
        msg_notic '\n%s\n' "• Docker compose version"
        docker compose version
    fi

    printf '\n%s%s\n%s%s\n\n' "$(tput setaf 4)$(tput bold)" \
    "Complete! Please use \"docker run hello-world\" to test." \
    "The log of this execution can be found at ${LOGFILE}" \
    "$(tput sgr0)" >&3
}
