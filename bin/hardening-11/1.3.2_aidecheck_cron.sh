#!/bin/bash

# run-shellcheck
#
# CIS Debian Hardening
#

#
# 1.3.2 Ensure filesystem integrity is regularly checked (Automated)
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=4
CIS_S_LEVEL=1
CIS_W_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure filesystem integrity is regularly checked (Automated)"

# Note : in CIS, AIDE has been chosen, however we chose tripwire

FILES="/etc/crontab"
DIRECTORY="/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly"
PATTERN='^([^#\n\r]+\h+)?(\/usr\/s?bin\/|^\h*)aide(\.wrapper)?\h+(--check|([^#\n\r]+\h+)?\$AIDEARGS)\b'

# This function will be called if the script status is on enabled / audit mode
audit() {
    FILES="$FILES $($SUDO_CMD find $DIRECTORY -type f)"
    FOUND=0
    for FILE in $FILES; do
	does_perl_pattern_exist_in_file "$FILE" "$PATTERN"
        if [ "$FNRET" = 0 ]; then
            FOUND=1
	    ok "$PATTERN is present in $FILE"
	    break
        fi
    done
    if [ $FOUND != 1 ]; then
        crit "$PATTERN is not present in $FILES"
    fi
}

# This function will be called if the script status is on enabled mode
apply() {
    FILES="$FILES $($SUDO_CMD find $DIRECTORY -type f)"
    FOUND=0
    for FILE in $FILES; do
	does_perl_pattern_exist_in_file "$FILE" "$PATTERN"
        if [ "$FNRET" = 0 ]; then
            FOUND=1
        fi
    done
    if [ "$FOUND" != 1 ]; then
        warn "$PATTERN is not present in $FILES, setting tripwire cron"
        echo "0 10 * * * root /usr/sbin/tripwire --check > /dev/shm/tripwire_check 2>&1 " >/etc/cron.d/CIS_8.3.2_tripwire
    else
        ok "$PATTERN is present in $FILES"
    fi
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    # shellcheck source=../../debian/default
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
    echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
    echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r "$CIS_ROOT_DIR"/lib/main.sh ]; then
    # shellcheck source=../../lib/main.sh
    . "$CIS_ROOT_DIR"/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
