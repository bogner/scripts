#!/bin/bash
# dereference all the symlinks in a path
usage="$0 filename"

function die() {
    echo "$1"
    exit 1
}

deref_path=""
function dereference() {
    if [ "$1" = "/" ]; then
        echo "$deref_path/" | rev
        return
    fi
    if [[ $1 != /* ]]; then
        path="$PWD/$1"
    else
        path="$1"
    fi
    while [ -h "$path" ]; do
        target="$(ls -l $path | awk -F" -> " '{print $2}')"
        if [[ $target != /* ]]; then
            path="$(cd "$(dirname "$path")"; pwd )/$target"
        else
            path="$target"
        fi
    done
    if [ -z "$deref_path" ]; then
        deref_path="$(basename "$path" | rev)"
    else
        deref_path="$deref_path/$(basename "$path" | rev)"
    fi
    dereference "$(dirname "$path")"
}

[ $# -ne 1 ] && die usage
dereference $1
