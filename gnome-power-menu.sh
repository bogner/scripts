#!/bin/bash

gnome-power-cmd.sh $(zenity --list --width 256 --height 256 \
    --text "How would you like to exit?" \
    --column "" suspend shutdown hibernate reboot)
