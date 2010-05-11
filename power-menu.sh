#!/bin/bash

die () { echo "$0: $@"; exit 1; }

if [ $# -gt 0 ]; then
    cmd=$@
else
    cmd=$(zenity --list --width 256 --height 264 \
        --text "How would you like to exit?" \
        --column "" "blank screen" hibernate lock reboot shutdown suspend)
fi

case $cmd in
    "blank screen") xset dpms force off;;
    lock) xlock;;
    reboot) gksu "shutdown -r now";;
    shutdown) gksu "shutdown -h now";;
    suspend|hibernate) gksu "pm-$cmd";;
    *) die "unknown command: $cmd";;
esac
