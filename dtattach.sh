#!/bin/bash
# attach to a running dtach session
usage="$0 [ socket_prefix | path_to_socket ]"

function die() {
    echo "$0: $1"
    exit 1
}

[ $# -eq 1 ] || die "$usage"
[ -e $1 ] && SOCK=$1 || SOCK=~/.dtach/$1.dtach

dtach -a $SOCK -e ^d
