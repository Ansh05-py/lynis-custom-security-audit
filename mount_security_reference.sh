#!/bin/sh

#########################################################################
#
#-----------------------------------------------------
# PLUGIN_AUTHOR=Your Name
# PLUGIN_CATEGORY=Custom
# PLUGIN_DESC=Filesystem Mount Options Security Audit
# PLUGIN_NAME=mount_security
# PLUGIN_VERSION=1.0
# PLUGIN_REQUIRED_TESTS=
#-----------------------------------------------------
#
#########################################################################

InsertSection "Custom Filesystem Security Audit"

##############################################################################
# Test        : CUS-0501
# Description : Check secure mount options for important mount points
##############################################################################

Register --test-no CUS-0501 --weight L --network NO --description "Check secure mount options"

if [ ${SKIPTEST} -eq 0 ]; then

    Display --indent 2 --text "- Checking secure mount options..."

    for MOUNTPOINT in /tmp /var/tmp /dev/shm /run /home
    do

        OPTIONS=$(findmnt -n -o OPTIONS $MOUNTPOINT 2>/dev/null)

        if [ ! -z "$OPTIONS" ]; then

            Display --indent 4 --text "- Checking $MOUNTPOINT"

            echo "$OPTIONS" | grep -q nodev
            if [ $? -ne 0 ]; then
                ReportWarning ${TEST_NO} "$MOUNTPOINT missing nodev mount option"
                ReportSuggestion ${TEST_NO} "Add nodev mount option to $MOUNTPOINT"
            fi

            echo "$OPTIONS" | grep -q nosuid
            if [ $? -ne 0 ]; then
                ReportWarning ${TEST_NO} "$MOUNTPOINT missing nosuid mount option"
                ReportSuggestion ${TEST_NO} "Add nosuid mount option to $MOUNTPOINT"
            fi

            echo "$OPTIONS" | grep -q noexec
            if [ $? -ne 0 ]; then
                ReportWarning ${TEST_NO} "$MOUNTPOINT missing noexec mount option"
                ReportSuggestion ${TEST_NO} "Add noexec mount option to $MOUNTPOINT"
            fi

        else

            Display --indent 4 --text "- $MOUNTPOINT not mounted separately"

        fi

    done

fi
