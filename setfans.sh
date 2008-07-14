#!/bin/bash
# set the fan speeds, or let the cpu take over again

# might need the next couple commands...
# modprobe applesmc
# echo applesmc | sudo tee -a /etc/modules

hddtemp /dev/sda
sensors

if [ $# -lt 1 ]; then
    echo setting fans to auto...
    echo 0 > /sys/devices/platform/applesmc.768/fan1_manual
    echo 0 > /sys/devices/platform/applesmc.768/fan2_manual
elif [ "$1" -gt 6000 ] || [ "$1" -lt 2000 ]; then
    echo "speed must be in between 2000RPM and 6000RPM"
    exit 1
else
    echo setting fans to $1...
    echo 1 > /sys/devices/platform/applesmc.768/fan1_manual
    echo $1 > /sys/devices/platform/applesmc.768/fan1_output
    echo 1 > /sys/devices/platform/applesmc.768/fan2_manual
    echo $1 > /sys/devices/platform/applesmc.768/fan2_output
fi
