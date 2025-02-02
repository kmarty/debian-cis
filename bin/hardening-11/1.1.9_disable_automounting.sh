#!/bin/bash

# run-shellcheck
#
# CIS Debian Hardening
#

#
# 1.1.9 Disable Automounting (Automated)
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
CIS_S_LEVEL=1
CIS_W_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Disable Automounting (Automated)"

SERVICE_NAME="autofs"

# This function will be called if the script status is on enabled / audit mode
audit() {
    info "Checking if $SERVICE_NAME is enabled"
    is_service_enabled "$SERVICE_NAME"
    if [ "$FNRET" = 0 ]; then
        crit "$SERVICE_NAME is enabled"
    else
        ok "$SERVICE_NAME is disabled"
    fi
}

# This function will be called if the script status is on enabled mode
apply() {
    info "Checking if $SERVICE_NAME is enabled"
    is_service_enabled "$SERVICE_NAME"
    if [ "$FNRET" = 0 ]; then
        info "Disabling $SERVICE_NAME"
	systemctl stop "$SERVICE_NAME" >/dev/null 2>&1
	systemctl mask "$SERVICE_NAME" >/dev/null 2>&1
    else
        ok "$SERVICE_NAME is disabled"
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
