#!/bin/bash

cmd=$(zenity --list --width 256 --height 264 \
    --text "How would you like to exit?" \
    --column "" lock suspend shutdown hibernate reboot cancel)

case $cmd in
    suspend|shutdown|hibernate|reboot)
        gnome-power-cmd $cmd
        ;;
    lock)
        xlock
        ;;
    *)
        ;;
esac
