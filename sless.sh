#!/bin/bash
# ssh + less

usage="$0 host:path"
die () {
    echo $@
    exit
}

[ $# -eq 1 ] && [[ "$1" == *:* ]] || die "$usage"

host=${1%%:*}
path=${1#*:}

ssh $host cat $path | less
