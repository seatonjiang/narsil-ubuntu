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

export LC_ALL=C.UTF-8

set -u -o pipefail

# Check Permission
if (( EUID != 0 )); then
    printf '%s\n\n' "$(tput setaf 1)$(tput bold)Error: Narsil must run as root. Either use sudo or 'sudo bash ${0}'!$(tput sgr0)" >&2
    exit 1
fi

# Check Ubuntu
if ! grep -Eqi "Ubuntu" /etc/os-release; then
    printf '%s\n\n' "$(tput setaf 1)$(tput bold)Error: Narsil is only available for Ubuntu!$(tput sgr0)" >&2
    exit 1
fi

# Path to the log file
LOGFILE=/var/log/narsil-$(date +%Y%m%d-%s).log

# Create log file
truncate -s0 "${LOGFILE}"

# Send all output to the logfile as well as stdout.
# Output to 1 goes to stdout and the logfile.
# Output to 2 goes to stderr and the logfile.
# Output to 3 just goes to stdout.
# Output to 4 just goes to stderr.
# Output to 5 just goes to the logfile.
# shellcheck disable=SC2094
exec \
    3>&1 \
    4>&2 \
    5>> "${LOGFILE}" \
    > >(tee -a "${LOGFILE}") \
    2> >(tee -a "${LOGFILE}" >&2)

# Single arg just gets returned verbatim, multi arg gets formatted via printf.
# First arg is the name of a variable to store the results.
function msg_format()
{
    local _VAR
    _VAR="$1"
    shift
    if (( $# > 1 )); then
        # shellcheck disable=SC2059
        printf -v "${_VAR}" "$@"
    else
        printf -v "${_VAR}" "%s" "$1"
    fi
}

# Send an info message to the log file and stdout.
function msg_info()
{
    local MSG
    msg_format MSG "$@"
    printf '%s' "${MSG}" >&5
    printf '%s%s%s' "$(tput setaf 4)$(tput bold)" "${MSG}" "$(tput sgr0)" >&3
}

# Send an notic message to the log file and stdout.
function msg_notic()
{
    local MSG
    msg_format MSG "$@"
    printf '%s' "${MSG}" >&5
    printf '%s%s%s' "$(tput setaf 3)$(tput bold)" "${MSG}" "$(tput sgr0)" >&3
}

# Send an success message to the log file and stdout.
function msg_succ()
{
    local MSG
    msg_format MSG "$@"
    printf '%s' "${MSG}" >&5
    printf '%s%s%s' "$(tput setaf 2)$(tput bold)" "${MSG}" "$(tput sgr0)" >&3
}

# Send an error message to the log file and stderr.
function msg_error()
{
    local MSG
    msg_format MSG "$@"
    printf '%s' "${MSG}" >&5
    printf '%s%s%s' "$(tput setaf 1)$(tput bold)" "${MSG}" "$(tput sgr0)" >&4
}

# shellcheck disable=SC1091
source narsil.conf

# shellcheck disable=SC1090
for SCRIPTS in scripts/narsil-*.sh; do
    [[ -f ${SCRIPTS} ]] || break
    source "${SCRIPTS}"
done

# shellcheck disable=SC2034
function narsil_logo()
{
    msg_info '%s\n'   '    _   __                    _  __    ______            __           '
    msg_info '%s\n'   '   / | / /____ _ _____ _____ (_)/ /   /_  __/___  ____  / /           '
    msg_info '%s\n'   '  /  |/ // __ `// ___// ___// // /     / / / __ \/ __ \/ /            '
    msg_info '%s\n'   ' / /|  // /_/ // /   (__  )/ // /     / / / /_/ / /_/ / /             '
    msg_info '%s\n\n' '/_/ |_/ \__,_//_/   /____//_//_/     /_/  \____/\____/_/              '
    msg_info '%s\n'   'This is the version for Ubuntu!                                       '
    msg_info '%s\n\n' 'For more information: https://github.com/seatonjiang/narsil-ubuntu    '
    msg_info '%s\n'   'Please read the manual and check the config before using the script.  '
    msg_info '%s\n'   'If there is a problem with the execution, please provide the log file.'

    STATS=1
}

function narsil_help()
{
    printf '%s\n' "$(tput setaf 3)$(tput bold)Usage:$(tput sgr0)"
    printf '%s\n\n' "   bash $0 [options]"
    printf '%s\n' "$(tput setaf 3)$(tput bold)Options:$(tput sgr0)"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -c, --clear$(tput sgr0)         Clear all syslog files, cache and backup folders"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -d, --docker$(tput sgr0)        Install docker service and set registry mirrors"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -f, --fdisk$(tput sgr0)         Interactive mount data disk"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -n, --hostname$(tput sgr0)      Change system hostname"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -p, --port$(tput sgr0)          Modify the SSH port"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -r, --removeagent$(tput sgr0)   Remove monitor from cloud servers"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -s, --swap$(tput sgr0)          Add swap space"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -v, --version$(tput sgr0)       Print version and quit"
    printf '%s\n' "$(tput setaf 2)$(tput bold)   -h, --help$(tput sgr0)          Get help for commands and quit"
    printf '\n%s\n' "$(tput setaf 3)$(tput bold)Help:$(tput sgr0)"
    printf '%s\n' "   If a problem is encountered, please provide the log file(/var/log/narsil-*.log)."
    printf '%s\n\n' "   Submit bug reports or suggestions to $(tput setaf 2)$(tput bold)https://github.com/seatonjiang/narsil-ubuntu/issues$(tput sgr0)"
}

function narsil_version()
{
    printf '%s\n\n' "Narsil version $(tput setaf 2)v1.0$(tput sgr0)"
}

function narsil_auto_check()
{
    if [ -e ~/.narsil ]; then
        msg_error '\n%s\n\n' "Error: Narsil initialization is complete, do not run it again!"
        exit 1
    fi
}

function narsil_reboot()
{
    echo 'Narsil initialization completed!' > ~/.narsil
    printf '\n%s%s\n%s%s\n\n' "$(tput setaf 4)$(tput bold)" \
    "Narsil is complete and the system is about to reboot." \
    "The log of this execution can be found at ${LOGFILE}" \
    "$(tput sgr0)" >&3
    reboot
}

# Reconfirm
function narsil_reconfirm()
{
    msg_info '\n%s' 'Press any key to start or Press Ctrl+C to cancel...'
    read -rsn1
    echo
}

function narsil_auto()
{
    clear
    narsil_logo
    narsil_auto_check
    narsil_reconfirm
    narsil_dnsserver
    narsil_timezone
    narsil_ntpserver
    narsil_sshdconfig
    narsil_useradd
    narsil_logindefs
    narsil_limits
    narsil_timeout
    narsil_tcpbbr
    narsil_apport
    narsil_debugshell
    narsil_ctrlaltdel
    narsil_removepackages
    narsil_banner
    narsil_reboot
}

if [ $# -eq 0 ];then
    narsil_auto
    exit 0
fi

while :; do
    [ -z "$1" ] && exit 0;
    case $1 in
        -c|--clear)
            clear
            narsil_logo
            narsil_clearlogs
            exit 0
        ;;
        -d|--docker)
            clear
            narsil_logo
            narsil_docker
            exit 0
        ;;
        -f|--fdisk)
            clear
            narsil_logo
            narsil_fdisk
            exit 0
        ;;
        -n|--hostname)
            clear
            narsil_logo
            narsil_hostname
            exit 0
        ;;
        -p|--port)
            clear
            narsil_logo
            narsil_sshport
            exit 0
        ;;
        -r|--removeagent)
            clear
            narsil_logo
            narsil_removeagent
            exit 0
        ;;
        -s|--swap)
            clear
            narsil_logo
            narsil_swap
            exit 0
        ;;
        -v|--version)
            narsil_version
            exit 0
        ;;
        -h|--help)
            narsil_help
            exit 0
        ;;
        *)
            printf '%s\n\n' "The \"$(tput setaf 1)$(tput bold)$1$(tput sgr0)\" option does not exist."
            exit 1
        ;;
    esac
done
