#!/bin/bash

# run-shellcheck
#
# CIS Debian Hardening
#

#
# 1.7.1.2 Ensure local login warning banner is configured properly (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=3
# shellcheck disable=2034
DESCRIPTION="Remove OS information from Login Warning Banners."

FILE='/etc/issue'
PATTERN='(\\v|\\r|\\m|\\s)'

# This function will be called if the script status is on enabled / audit mode
audit () {
    does_pattern_exist_in_file $FILE "$PATTERN"
    if [ "$FNRET" = 0 ]; then
        crit "$PATTERN is present in $FILE"
    else
        ok "$PATTERN is not present in $FILE"
    fi
}

# This function will be called if the script status is on enabled mode
apply () {
    does_pattern_exist_in_file $FILE "$PATTERN"
    if [ "$FNRET" = 0 ]; then
        warn "$PATTERN is present in $FILE"
        delete_line_in_file $FILE $PATTERN
    else
        ok "$PATTERN is not present in $FILE"
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
