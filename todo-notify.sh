#!/bin/bash
todo --use-format display=notify | \
    sed 's/&/&amp;/g' | \
    notify-cat.sh todo
