#!/bin/sh

#########################################################################
#
#-----------------------------------------------------
# PLUGIN_AUTHOR=ANEESH A
# PLUGIN_CATEGORY=Custom
# PLUGIN_DESC=DNS Resolver Security Audit
# PLUGIN_NAME=dns_security
# PLUGIN_VERSION=1.0
# PLUGIN_REQUIRED_TESTS=
#-----------------------------------------------------
#
#########################################################################

InsertSection "Custom DNS Security Audit"

##############################################################################
# Test        : CUS-0502
# Description : Check DNS resolver configuration
##############################################################################

Register --test-no CUS-0502 --weight L --network NO --description "Check DNS resolver configuration"

if [ ${SKIPTEST} -eq 0 ]; then

    Display --indent 2 --text "- Checking DNS resolver configuration..."

    RESOLV="/etc/resolv.conf"

    if [ ! -f "$RESOLV" ]; then

        ReportWarning ${TEST_NO} "$RESOLV does not exist"

    else

        NAMESERVERS=$(grep "^nameserver" "$RESOLV" | awk '{print $2}')

        if [ -z "$NAMESERVERS" ]; then
            ReportWarning ${TEST_NO} "No DNS nameserver configured"
            ReportSuggestion ${TEST_NO} "Configure at least one DNS nameserver"
        fi

        DUPLICATES=$(echo "$NAMESERVERS" | sort | uniq -d)

        if [ ! -z "$DUPLICATES" ]; then
            ReportWarning ${TEST_NO} "Duplicate DNS nameserver entries detected"
            ReportSuggestion ${TEST_NO} "Remove duplicate nameserver entries"
        fi

        # Check target file permissions, following symbolic links
        PERMS=$(stat -L -c "%a" "$RESOLV" 2>/dev/null)

        if [ -n "$PERMS" ]; then
            PERM_VALUE=$((0$PERMS))

            if [ $((PERM_VALUE & 022)) -ne 0 ]; then
                ReportWarning "${TEST_NO}" \
                    "Resolver target is writable by group or others (permissions: $PERMS)"
                ReportSuggestion "${TEST_NO}" \
                    "Review write permissions on the resolver configuration file"
            else
                Display --indent 4 --text \
                    "Resolver target has no group or other write permission"
            fi
        else
            ReportWarning "${TEST_NO}" \
                "Unable to determine resolver target permissions"
        fi

    fi

fi
