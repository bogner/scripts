#!/bin/bash

i=0
while [ $# -gt 0 ]; do
    case "$1" in
        --*)
            args[$((i++))]="$1"
            ;;
        -*)
            args[$((i++))]="$1 $2"
            shift
            ;;
        *)
            if [ -z "$title" ]; then
                title="$1"
            else
                title="$title $1"
            fi
            ;;
    esac
    shift
done
[ -z "$title" ] && read title
notify-send ${args[@]} "$title" "$(cat)"
