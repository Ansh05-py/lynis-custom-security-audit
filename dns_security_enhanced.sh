#!/bin/sh

#########################################################################
# PLUGIN_AUTHOR=ANEESH A
# PLUGIN_CATEGORY=Custom
# PLUGIN_DESC=Enhanced DNS Resolver Security Audit
# PLUGIN_NAME=dns_security
# PLUGIN_VERSION=2.0
# PLUGIN_REQUIRED_TESTS=
#########################################################################

InsertSection "Enhanced DNS Resolver Security Audit"

Register --test-no CUS-0503 --weight M --network NO \
    --description "Enhanced DNS resolver security and reliability audit"

if [ "${SKIPTEST}" -eq 0 ]; then

    RESOLV="/etc/resolv.conf"

    Display --indent 2 --text "Checking DNS resolver security"

    if [ ! -f "$RESOLV" ]; then

        Display --indent 4 --text "Resolver file" \
            --result WARNING --color RED

        ReportWarning "${TEST_NO}" \
            "$RESOLV does not exist"

        ReportSuggestion "${TEST_NO}" \
            "Create and configure a valid DNS resolver file"

    else

        Display --indent 4 --text "Resolver file exists" \
            --result OK --color GREEN

        # Check nameserver configuration
        NAMESERVERS=$(awk '$1 == "nameserver" {print $2}' "$RESOLV")

        NS_COUNT=$(printf '%s\n' "$NAMESERVERS" |
            awk 'NF' | sort -u | wc -l)

        if [ "$NS_COUNT" -eq 0 ]; then

            Display --indent 4 --text "Nameserver configuration" \
                --result WARNING --color RED

            ReportWarning "${TEST_NO}" \
                "No DNS nameserver configured"

            ReportSuggestion "${TEST_NO}" \
                "Configure at least one valid DNS nameserver"

        else

            Display --indent 4 --text "Nameserver configuration" \
                --result OK --color GREEN

        fi

        # Check duplicate nameservers
        DUPLICATES=$(printf '%s\n' "$NAMESERVERS" |
            awk 'NF' | sort | uniq -d)

        if [ -n "$DUPLICATES" ]; then

            Display --indent 4 --text "Duplicate nameservers" \
                --result WARNING --color RED

            ReportWarning "${TEST_NO}" \
                "Duplicate DNS nameserver entries detected"

            ReportSuggestion "${TEST_NO}" \
                "Remove duplicate nameserver entries"

        else

            Display --indent 4 --text "Duplicate nameservers" \
                --result OK --color GREEN

        fi

        # Check resolver file permissions
        PERMS=$(stat -L -c "%a" "$RESOLV" 2>/dev/null)

        if [ -n "$PERMS" ]; then

            PERM_VALUE=$((0$PERMS))

            if [ $((PERM_VALUE & 022)) -ne 0 ]; then

                Display --indent 4 --text "Resolver permissions" \
                    --result WARNING --color RED

                ReportWarning "${TEST_NO}" \
                    "Resolver file is writable by group or others"

                ReportSuggestion "${TEST_NO}" \
                    "Review resolver file write permissions"

            else

                Display --indent 4 --text "Resolver permissions" \
                    --result OK --color GREEN

            fi

        else

            Display --indent 4 --text "Resolver permissions" \
                --result WARNING --color RED

            ReportWarning "${TEST_NO}" \
                "Unable to determine resolver file permissions"

        fi

        # Enhancement 1: DNS server redundancy
        if [ "$NS_COUNT" -ge 2 ]; then

            Display --indent 4 --text "DNS server redundancy" \
                --result OK --color GREEN

        else

            Display --indent 4 --text "DNS server redundancy" \
                --result WARNING --color RED

            ReportWarning "${TEST_NO}" \
                "Fewer than two unique DNS nameservers configured"

            ReportSuggestion "${TEST_NO}" \
                "Consider configuring a second trusted DNS nameserver"

        fi

        # Enhancement 2: DNS timeout configuration
        TIMEOUT=$(awk '
            $1 == "options" {
                for (i=2; i<=NF; i++)
                    if ($i ~ /^timeout:/) {
                        sub(/^timeout:/, "", $i)
                        print $i
                    }
            }' "$RESOLV" | tail -n 1)

        case "$TIMEOUT" in
            ''|*[!0-9]*|0)
                TIMEOUT_VALID=0
                ;;
            *)
                if [ "$TIMEOUT" -le 5 ]; then
                    TIMEOUT_VALID=1
                else
                    TIMEOUT_VALID=0
                fi
                ;;
        esac

        if [ "$TIMEOUT_VALID" -eq 1 ]; then

            Display --indent 4 --text "DNS timeout configuration" \
                --result OK --color GREEN

        else

            Display --indent 4 --text "DNS timeout configuration" \
                --result WARNING --color RED

            ReportWarning "${TEST_NO}" \
                "DNS timeout is missing or outside the recommended range"

            ReportSuggestion "${TEST_NO}" \
                "Configure an explicit timeout value between 1 and 5 seconds"

        fi

        # Enhancement 3: DNS retry configuration
        ATTEMPTS=$(awk '
            $1 == "options" {
                for (i=2; i<=NF; i++)
                    if ($i ~ /^attempts:/) {
                        sub(/^attempts:/, "", $i)
                        print $i
                    }
            }' "$RESOLV" | tail -n 1)

        case "$ATTEMPTS" in
            ''|*[!0-9]*|0)
                ATTEMPTS_VALID=0
                ;;
            *)
                if [ "$ATTEMPTS" -le 5 ]; then
                    ATTEMPTS_VALID=1
                else
                    ATTEMPTS_VALID=0
                fi
                ;;
        esac

        if [ "$ATTEMPTS_VALID" -eq 1 ]; then

            Display --indent 4 --text "DNS retry configuration" \
                --result OK --color GREEN

        else

            Display --indent 4 --text "DNS retry configuration" \
                --result WARNING --color RED

            ReportWarning "${TEST_NO}" \
                "DNS retry setting is missing or outside the recommended range"

            ReportSuggestion "${TEST_NO}" \
                "Configure an explicit attempts value between 1 and 5"

        fi

    fi

fi

# EOF
