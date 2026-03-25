#!/bin/bash
# json_get — extract a string value from a flat JSON file
# Usage: json_get <key> <file>
# Returns the string value for the given key, or empty string.
# Limitation: string values only, no nested objects/arrays.
json_get() {
    local key="$1" file="$2"
    grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" 2>/dev/null \
        | sed "s/\"${key}\"[[:space:]]*:[[:space:]]*\"//;s/\"$//"
}
