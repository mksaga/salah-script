#!/bin/bash

# Salah.sh: a command-line utility for getting salah times 

current_time="$(date '+%H:%M')"
echo ""
echo "Welcome!"
echo "Current Time: $current_time"
echo ""

# No arguments provided:
if [ $# == 0 ]; then
    echo "hi";
fi
