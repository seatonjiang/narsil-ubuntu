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

function narsil_logindefs()
{
    msg_info '\n%s\n' "[${STATS}] Change user login policy"

    VERIFY=${VERIFY:-'Y'}

    # Password can be used for a maximum of 30 days
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 30/' /etc/login.defs
    # 1 day between password changes
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/' /etc/login.defs
    # Password minimum 12 digits
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/' /etc/login.defs
    # Warning 7 days before password expiration
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs
    # Disable login for users without home directory
    sed -i 's/^.*DEFAULT_HOME.*/DEFAULT_HOME no/' /etc/login.defs
    # Set the system default encryption algorithm to SHA512
    sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
    # Disable synchronous deletion of user groups when deleting users
    sed -i 's/^USERGROUPS_ENAB.*/USERGROUPS_ENAB no/' /etc/login.defs

    sed -i 's@^.*ENV_SUPATH.*@ENV_SUPATH PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin@' /etc/login.defs
    sed -i 's@^.*ENV_PATH.*@ENV_PATH PATH=/usr/local/bin:/usr/bin:/bin:/snap/bin@' /etc/login.defs

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• File Content: /etc/login.defs"
        grep -Ev '^#|^$' /etc/login.defs | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
