#!/bin/bash

host=${1:-localhost}
res=$(xdpyinfo | awk '/dimensions/ {print $2}' | awk -Fx '{print $1 "x" $2-24}')
rdesktop -E -g$res $host
