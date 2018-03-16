#!/usr/bin/env bash

file_exists () {
    FILE=$1
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}


touch_file () {
    file=$1
    touch "$file" &&
    echo "File $file created."
}

trim () {
    local trimmed="$1"

    # Strip leading space.
    trimmed="${trimmed## }"
    # Strip trailing space.
    trimmed="${trimmed%% }"

    echo "$trimmed"
}
