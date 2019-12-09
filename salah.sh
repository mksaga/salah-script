#!/bin/bash

# Salah.sh: a command-line utility for getting salah times

declare -r times_url=https://www.salahtimes.com/usa/philadelphia

current_time="$(date '+%H:%M')"
echo ""
echo "Welcome!"
echo "Current Time: $current_time"
echo ""

# No arguments provided:
if [ $# == 0 ]; then
    echo "hi";
    num_days_this_month=$(cal $(date +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')
    num_lines=$((9 * $num_days_this_month))
    num_lines=$(($num_lines + 2))
    # start_line= $(grep -n "<table class=\"table table-responsive table-condensed table-prayertimes table-prayertimes-month table-hover hidden\">" philadelphia | cut -d ':' -f 1)
    # cat philadelphia
    # echo $start_line
    # echo $num_lines
    echo $num_lines

    # get "Dec 2019"
    mon_yr=$(date "+%h %Y")

    # Find the line of the second occurence of "Dec 2019"
    wget -O philly $times_url
    start_line_num=$(awk -v mon_yr="$mon_yr" '$0 ~ mon_yr {i++}i==2{print NR; exit}' philly)
    echo $start_line_num
    echo  $mon_yr
    start_line_num=$(($start_line_num - 1))

    # Delete lines up to second occurrence of "Dec 2019"
    sed 1,"$start_line_num"d philly > za_philly

    # Find line holding the end of the table
    end_line_num=$(awk '/\/tbody/{print NR; exit}' za_philly)
    echo $end_line_num

    # Delete content between Dec 2019 and start of table
    start_line_num=$(awk '/\/thead/{print NR; exit}' za_philly)
    sed 1,"$start_line_num"d za_philly > final_philly

    # Delete content after the table
    sed '/\/table/,$d' final_philly > complete_philly

    # Cleanup
    rm final_philly za_philly philly


    # echo $start_line_num
    # find the first Dec 2019
    # find the first following <tbody>
    # grab everything from there to </tbody>

fi

# 9 lines per day + tbody + /tbody
