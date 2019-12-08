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
    grep "<table class=\"table table-responsive table-condensed table-prayertimes table-prayertimes-month table-hover hidden\">" philadelphia -n -A 296 | grep tbody -A 281 > times3.txt
fi
