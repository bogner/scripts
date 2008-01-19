#!/bin/bash
#frontend for "echo | bc" with a default scale of 8
echo "scale=8; $@" | bc | sed 's/0\+$/0/'
