#!/bin/bash
# watch the date, accurate to the minute
format="%-Y-%-m-%-d %-H:%M"

date +"$format"
while [ $(date +%S) -ne 0 ]; do
    sleep 1;
done
while [ 0 ]; do
    date +"$format"
    sleep 60
done
