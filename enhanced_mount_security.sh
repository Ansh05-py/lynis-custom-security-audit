#!/bin/sh

# PLUGIN_AUTHOR=ANEESH A
# PLUGIN_CATEGORY=Custom
# PLUGIN_DESC=Enhanced Filesystem Mount Security Audit
# PLUGIN_NAME=mount_security
# PLUGIN_VERSION=2.0
# PLUGIN_REQUIRED_TESTS=

InsertSection "Linux Filesystem Mount Security Audit"

Register --test-no MOUNT-0001 --weight M --network NO \
    --description "Audit effective filesystem mount security options"

if [ "${SKIPTEST}" -eq 0 ]; then

    check_mount()
    {
        MOUNTPOINT="$1"
        REQUIRED_OPTIONS="$2"

        EFFECTIVE_TARGET=$(findmnt -n -o TARGET --target "$MOUNTPOINT" 2>/dev/null)
        OPTIONS=$(findmnt -n -o OPTIONS --target "$MOUNTPOINT" 2>/dev/null)

        if [ -z "$EFFECTIVE_TARGET" ] || [ -z "$OPTIONS" ]; then
            Display --indent 2 --text "Checking $MOUNTPOINT" \
                --result "NOT FOUND" --color YELLOW
            LogText "Unable to determine mount information for $MOUNTPOINT"
            return
        fi

        Display --indent 2 --text "Checking $MOUNTPOINT"
        LogText "Effective mount for $MOUNTPOINT: $EFFECTIVE_TARGET"
        LogText "Mount options: $OPTIONS"

        if [ "$EFFECTIVE_TARGET" != "$MOUNTPOINT" ]; then
            Display --indent 4 --text \
                "$MOUNTPOINT shares mount $EFFECTIVE_TARGET"
        fi

        OLD_IFS="$IFS"
        IFS=,

        for OPTION in $REQUIRED_OPTIONS
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

        IFS="$OLD_IFS"
    }

    check_mount "/tmp" "nodev,nosuid,noexec"
    check_mount "/var/tmp" "nodev,nosuid,noexec"
    check_mount "/dev/shm" "nodev,nosuid,noexec"
    check_mount "/proc" "nodev,nosuid,noexec"
    check_mount "/sys" "nodev,nosuid,noexec"

fi