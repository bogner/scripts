#!/bin/bash
# Wrapper for cmake that logs the invocation for future reference.

should_emit_invocation () {
    for arg in "$@"; do
        case "$arg" in
            -P|-E|-N) return 1;;
            -L|-LA|-LH|-LAH) return 1;;
            --build) return 1;;
            --find-package) return 1;;
            --graphviz=*) return 1;;
            --system-information) return 1;;
            --help|-help|-usage|-h|-H|/?) return 1;;
            --version|-version|/V) return 1;;
            --help-*) return 1;;
            -H*|-B*) return 1;;
        esac
    done
    return 0
}

remove_from_path () {
    # Double up colons to handle repeated entries
    PATH=":$PATH:"
    PATH=${PATH//":"/"::"}
    # Remove matching entries
    PATH=${PATH//":$1:"/}
    # Clean up extra colons
    PATH=${PATH//"::"/":"}
    PATH=${PATH#:}
    PATH=${PATH%:}
}

escape () {
    printf "%q " "$@"
    printf '\n'
}

# Remove this directory from the path to prevent infinite recursion.
remove_from_path "$(dirname $0)"

if should_emit_invocation "$@"; then
    real_cmake="$(escape "$(which cmake)")"
    if ! [ -e cmake.command ] ||
            [[ $(tail -1 cmake.command) != "$real_cmake $(escape $@)" ]]; then
        echo "$real_cmake $(escape $@)" >> cmake.command
    fi
fi

# Now call the real cmake.
exec cmake "$@"
