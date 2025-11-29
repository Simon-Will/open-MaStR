#!/usr/bin/env bash

set -o pipefail

validate_all() {
    local unzipped_export="$1"
    local unzipped_documentation="$2"
    local xsd="${unzipped_documentation}/xsd"

    if ! command -v xmllint >/dev/null; then
        echo "xmllint is not installed."
        exit 1
    fi

    for xsd_file in "$xsd"/*.xsd; do
        xsd_name=$(basename "${xsd_file%.xsd}")
        echo "=== Validating $xsd_name ==="
        for xml_file in "${unzipped_export}/$xsd_name"*.xml; do
            # Validate, discard last line (that says if it validates or not), group and count validation errors.
            xmllint --noout --schema "$xsd_file" "$xml_file" 2>&1 | sed '$d' | sort | uniq -c
            # Reproduce last line manually. Relies on pipefail option to check if xmllint failed or not.
            if [ "$?" = 0 ]; then
                echo "$xml_file validates"
            else
                echo "$xml_file fails to validate"
            fi
        done
    done
}

validate_all "$@"
