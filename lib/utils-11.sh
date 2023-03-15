# shellcheck shell=bash
# CIS Debian Hardening Utility functions

# run-shellcheck

#
# Service Boot Checks
#

is_service_enabled() {
    local SERVICE=$1
    if ( $SUDO_CMD systemctl is-enabled "$SERVICE" > /dev/null 2>&1 ); then
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

# Verify $1 is a partition
is_a_partition() {
    local PARTITION=$1
    FNRET=128
    if findmnt --noheadings --kernel "$PARTITION" >/dev/null; then 
	FNRET=0
    else
	debug "Unable to find $PARTITION"
	FNRET=1
    fi
}

# Verify $1 has the proper option $2 in fstab
has_mount_option() {
    local PARTITION=$1
    local OPTION=$2
    if [ "$(findmnt --noheadings --kernel "$PARTITION" | grep "$OPTION")" ]; then
        FNRET=0
    else
        debug "Unable to find $OPTION for partition $PARTITION"
        FNRET=1
    fi
}

