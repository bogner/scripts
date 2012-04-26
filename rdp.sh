#!/bin/bash

host=${1:-localhost}
port=${2:-3389}
res=$(xdpyinfo | awk '/dimensions/ {print $2}' | awk -Fx '{print $1 "x" $2-24}')

rdesktop -K -E -g$res $host:$port
