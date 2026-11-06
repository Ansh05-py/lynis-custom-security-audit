#!/bin/sh

#########################################################################
# PLUGIN_AUTHOR=Ansh
# PLUGIN_CATEGORY=Filesystem
# PLUGIN_DESC=Linux Filesystem Mount Security Audit
# PLUGIN_NAME=mount_security
# PLUGIN_VERSION=2.0
# PLUGIN_REQUIRED_TESTS=
#########################################################################

InsertSection "Linux Filesystem Mount Security Audit"

Register --test-no MOUNT-0001 --weight M --network NO \
    --description "Audit effective filesystem mount security options"

if [ "${SKIPTEST}" -eq 0 ]; then

    check_mount()
    {
        MOUNTPOINT="$1"
        REQUIRED_OPTIONS="$2"

        MOUNT_INFO=$(findmnt -n -o TARGET,OPTIONS --target "$MOUNTPOINT" 2>/dev/null)

        if [ -z "$MOUNT_INFO" ]; then
            Display --indent 2 --text "Checking $MOUNTPOINT" \
                --result "NOT FOUND" --color YELLOW
            LogText "Unable to determine mount information for $MOUNTPOINT"
            return
        fi

        EFFECTIVE_TARGET=$(printf '%s\n' "$MOUNT_INFO" | awk '{print $1}')
        OPTIONS=$(printf '%s\n' "$MOUNT_INFO" | cut -d ' ' -f 2-)

        Display --indent 2 --text "Checking $MOUNTPOINT"
        LogText "Effective mount for $MOUNTPOINT: $EFFECTIVE_TARGET"
        LogText "Mount options: $OPTIONS"

        if [ "$EFFECTIVE_TARGET" != "$MOUNTPOINT" ]; then
            Display --indent 4 --text \
                "$MOUNTPOINT shares mount $EFFECTIVE_TARGET"
        fi

        OLD_IFS="$IFS"
        IFS=,
	set -- $REQUIRED_OPTIONS
	IFS="$OLD_IFS"
        for OPTION
        do
            case ",$OPTIONS," in
                *,"$OPTION",*)
                    Display --indent 4 --text "$OPTION" \
                        --result OK --color GREEN
                    ;;
                *)
                    Display --indent 4 --text "$OPTION" \
                        --result WARNING --color RED
                    ReportWarning "${TEST_NO}" \
                        "$OPTION missing for $MOUNTPOINT (effective mount: $EFFECTIVE_TARGET)"
                    ReportSuggestion "${TEST_NO}" \
                        "Review whether $OPTION can safely be enabled on $EFFECTIVE_TARGET"
                    ;;
            esac
        done
    }

    # Temporary storage
    check_mount "/tmp" "nodev,nosuid,noexec"
    check_mount "/var/tmp" "nodev,nosuid,noexec"
    check_mount "/dev/shm" "nodev,nosuid,noexec"

    # Kernel-managed filesystems: check only relevant restrictions
    check_mount "/proc" "nodev,nosuid,noexec"
    check_mount "/sys" "nodev,nosuid,noexec"

fi

# EOF
