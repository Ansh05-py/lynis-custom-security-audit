#!/bin/sh

InsertSection "Enhanced DNS Resolver Security Audit"

Register --test-no CUS-0502 --weight L --network NO \
    --description "Audit DNS resolver configuration and target permissions"

if [ "${SKIPTEST}" -eq 0 ]; then

    Display --indent 2 --text "Checking DNS resolver configuration"

    RESOLV="/etc/resolv.conf"

    if [ ! -f "$RESOLV" ]; then
        ReportWarning "${TEST_NO}" "$RESOLV does not exist"
        ReportSuggestion "${TEST_NO}" "Verify the resolver configuration path"
    else

        NAMESERVERS=$(grep '^[[:space:]]*nameserver[[:space:]]' "$RESOLV" | awk '{print $2}')

        if [ -z "$NAMESERVERS" ]; then
            ReportWarning "${TEST_NO}" "No DNS nameserver configured"
            ReportSuggestion "${TEST_NO}" "Configure at least one DNS nameserver"
        else
            DUPLICATES=$(printf '%s\n' "$NAMESERVERS" | sort | uniq -d)

            if [ -n "$DUPLICATES" ]; then
                ReportWarning "${TEST_NO}" "Duplicate DNS nameserver entries detected"
                ReportSuggestion "${TEST_NO}" "Review and remove duplicate nameserver entries"
            else
                Display --indent 4 --text "No duplicate nameserver entries detected"
            fi
        fi

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