# shellcheck shell=bash
# CIS Debian Hardening Utility functions

# run-shellcheck

#
# Service Boot Checks
#

is_service_enabled() {
    local SERVICE=$1
    if [ "$($SUDO_CMD find /etc/rc?.d/ -name "S*$SERVICE" -print | wc -l)" -gt 0 ]; then
        debug "Service $SERVICE is enabled"
        FNRET=0
    else
        debug "Service $SERVICE is disabled"
        FNRET=1
    fi
}


#
# Mounting point
#

# Verify $1 is a partition declared in fstab
is_a_partition() {
    local PARTITION=$1
    FNRET=128
    if [ ! -f /etc/fstab ] || [ -z "$(sed '/^#/d' /etc/fstab)" ]; then
        debug "/etc/fstab not found or empty, searching mountpoint"
        if mountpoint -q "$PARTITION"; then
            FNRET=0
        fi
    else
        if grep "[[:space:]]$1[[:space:]]" /etc/fstab | grep -vqE "^#"; then
            debug "$PARTITION found in fstab"
            FNRET=0
        else
            debug "Unable to find $PARTITION in fstab"
            FNRET=1
        fi

    fi
}

# Verify $1 has the proper option $2 in fstab
has_mount_option() {
    local PARTITION=$1
    local OPTION=$2
    if [ ! -f /etc/fstab ] || [ -z "$(sed '/^#/d' /etc/fstab)" ]; then
        debug "/etc/fstab not found or empty, reading current mount options"
        has_mounted_option "$PARTITION" "$OPTION"
    else
        if grep "[[:space:]]${PARTITION}[[:space:]]" /etc/fstab | grep -vE "^#" | awk '{print $4}' | grep -q "bind"; then
            local actual_partition
            actual_partition="$(grep "[[:space:]]${PARTITION}[[:space:]]" /etc/fstab | grep -vE "^#" | awk '{print $1}')"
            debug "$PARTITION is a bind mount of $actual_partition"
            PARTITION="$actual_partition"
        fi
        if grep "[[:space:]]${PARTITION}[[:space:]]" /etc/fstab | grep -vE "^#" | awk '{print $4}' | grep -q "$OPTION"; then
            debug "$OPTION has been detected in fstab for partition $PARTITION"
            FNRET=0
        else
            debug "Unable to find $OPTION in fstab for partition $PARTITION"
            FNRET=1
        fi
    fi
}

