#!/bin/bash

# Usage: ./extract_yaml.sh 'YAML content as a single string' "source_identifier"

if [ $# -ne 2 ]; then
    echo "Usage: $0 'YAML content' 'source_identifier'"
    exit 1
fi

yaml_content="$1"
target_source="$2"

echo "$yaml_content" | awk -v target_source="$target_source" '
BEGIN { in_section = 0; }
/^---/ {
    in_section = 0;
}
/^# Source: / {
    source_line = substr($0, 11);
    if (source_line == target_source) {
        in_section = 1;
        print "---";
        print $0;
        next;
    } else {
        in_section = 0;
    }
}
{
    if (in_section) {
        print $0;
    }
}
'
