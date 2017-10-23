#!/bin/zsh
# Wrapper for cmake that logs the invocation for future reference.

should_emit_invocation () {
    [ -z "$argv[(r)-P|-E|-N]" ]                     || return
    [ -z "$argv[(r)-L|-LA|-LH|-LAH]" ]              || return
    [ -z "$argv[(r)--build]" ]                      || return
    [ -z "$argv[(r)--find-package]" ]               || return
    [ -z "$argv[(r)--graphviz=*]" ]                 || return
    [ -z "$argv[(r)--system-information]" ]         || return
    [ -z "$argv[(r)--help|-help|-usage|-h|-H|/?]" ] || return
    [ -z "$argv[(r)--version|-version|/V]" ]        || return
    [ -z "$argv[(r)--help-*]" ]                     || return
    [ -z "$argv[(r)-H*|-B*]" ]                      || return
    return
}

# Remove this directory from the path to prevent infinite recursion.
path=("${(@)path:#$(dirname $0)}")

if should_emit_invocation "$@"; then
    real_cmake="$(which cmake)"
    if ! [ -e cmake.command ] ||
            [[ $(tail -1 cmake.command) != "$real_cmake $@" ]]; then
        echo "$real_cmake ${(q-)@}" >> cmake.command
    fi
fi

# Now call the real cmake.
exec cmake "$@"
