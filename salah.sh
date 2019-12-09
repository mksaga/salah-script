#!/bin/bash

# Salah.sh: a command-line utility for getting salah times

declare -r times_url=https://www.salahtimes.com/usa/philadelphia

current_time="$(date '+%H:%M')"
mon_day="$(date '+%a %d')"
# echo ""
# echo "Welcome!"
# echo "Current Time: $current_time"
# echo ""

# No arguments provided: print the usage guide
if [ "$#" == 0 ]
then
    touch .config
    ./salah.sh -h
fi

# Print usage guide
if [ "$1" == '-h' ]
then
    echo "Usage: ./ptimes [-disp -update -alert]"
    echo "-disp:"
    echo -e "\ttoday:\tprints today's prayer times"
    echo -e "\td [1-31]:\tprints prayer times of day #"
    echo -e "\tweek:\tprints  prayer times for this week"
    echo ""
    echo -e "-update:\tDownloads latest prayer times for this month"
    echo -e "-alert: \tTODO"
fi

# Download new prayer times
if [ "$1" == '-update' ]
then
    # get "Dec 2019"
    mon_yr=$(date "+%h %Y")

    # Find the line of the second occurence of "Dec 2019"
    wget -O philly $times_url
    start_line_num=$(awk -v mon_yr="$mon_yr" '$0 ~ mon_yr {i++}i==2{print NR; exit}' philly)
    # echo $start_line_num
    # echo  $mon_yr
    start_line_num=$(($start_line_num - 1))

    # Delete lines up to second occurrence of "Dec 2019"
    sed 1,"$start_line_num"d philly > za_philly

    # Find line holding the end of the table
    end_line_num=$(awk '/\/tbody/{print NR; exit}' za_philly)
    # echo $end_line_num

    # Delete content between Dec 2019 and start of table
    start_line_num=$(awk '/\/thead/{print NR; exit}' za_philly)
    sed 1,"$start_line_num"d za_philly > final_philly

    # Delete content after the table
    sed '/\/table/,$d' final_philly > complete_philly

    # Cleanup
    rm final_philly za_philly philly

    # part2: convert the HTML table to a nice text format

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        sed -i 's_ *<.\{2\}>_b_' complete_philly
        sed -i 's_b\(.*\)_\1_' complete_philly
        sed -i 's_\(.\{4,5\}\)<.*_\1_' complete_philly
        sed -i 's_<.*_a_' complete_philly

        # Fix two-letter short dates to 3-letter
        sed -i 's_Su\(.*\)_Sun\1_' complete_philly
        sed -i 's_Mo\(.*\)_Mon\1_' complete_philly
        sed -i 's_Tu\(.*\)_Tue\1_' complete_philly
        sed -i 's_We\(.*\)_Wed\1_' complete_philly
        sed -i 's_Th\(.*\)_Thu\1_' complete_philly
        sed -i 's_Fr\(.*\)_Fri\1_' complete_philly
        sed -i 's_Sa\(.*\)_Sat\1_' complete_philly

        # Correct single-digit dates to two-digit
        sed -i '1,83s_\([A-Za-z ]*\) \([0-9]\)_\1 0\2_' complete_philly
        sed -i '/^[[:space:]]*$/d' complete_philly

    # sed requires the two empty ticks on macOS
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's_ *<.\{2\}>_b_' complete_philly
        sed -i '' 's_b\(.*\)_\1_' complete_philly
        sed -i '' 's_\(.\{4,5\}\)<.*_\1_' complete_philly
        sed -i '' 's_<.*_a_' complete_philly

        # Fix two-letter short dates to 3-letter
        sed -i '' 's_Su\(.*\)_Sun\1_' complete_philly
        sed -i '' 's_Mo\(.*\)_Mon\1_' complete_philly
        sed -i '' 's_Tu\(.*\)_Tue\1_' complete_philly
        sed -i '' 's_We\(.*\)_Wed\1_' complete_philly
        sed -i '' 's_Th\(.*\)_Thu\1_' complete_philly
        sed -i '' 's_Fr\(.*\)_Fri\1_' complete_philly
        sed -i '' 's_Sa\(.*\)_Sat\1_' complete_philly

        # Correct single-digit dates to two-digit
        sed -i '' '1,83s_\([A-Za-z ]*\) \([0-9]\)_\1 0\2_' complete_philly
        sed -i '' '/^[[:space:]]*$/d' complete_philly
    fi

    awk NF complete_philly > .times

elif [ "$1" == '-disp' ]
then
    if [ $# == 1 ]
    then
        ./salah.sh -h
    fi

    if [ "$2" == 'next' ]; then
        current_time="$(date '+%H:%M')"
        current_hr="$(date '+%H')"
        current_min="$(date '+%M')"

        while IFS= read -r line
        do
            if [[ $line =~ [A-Z].* ]]; then
                # echo $line
                if [[ $line == $mon_day ]]; then
                    echo "$line"
                    for i in {1..6}
                    do
                        read -r tyme
                        prayer_hr=$(echo $tyme | awk 'BEGIN { FS = ":" } ; { print $1 }')
                        prayer_min=$(echo $tyme | awk 'BEGIN { FS = ":" } ; { print $2 }')

                        # Account for 24hr time
                        if [ $i -eq 3 ]; then
                            if [ $prayer_hr -lt 11 ]; then
                                prayer_hr=$(($prayer_hr+12))
                            fi
                        elif [ $i -gt 3 ]; then
                            prayer_hr=$((prayer_hr+12))
                        fi
                        # echo "$prayer_hr"

                        # A salah lies ahead of us in a later hour
                        if [ $current_hr -lt $prayer_hr ]; then
                            echo -n "$prayer_hr:"
                            echo "$prayer_min"
                            # echo "all done!"
                            exit
                        fi

                        # A salah lies ahead of us in this hour
                        if [ $current_hr -eq $prayer_hr ]; then
                            if [ $current_min -lt $prayer_min ]; then
                                echo -n "$prayer_hr:"
                                echo "$prayer_min"
                                echo "all done!"
                                break
                            fi
                        fi

                        # No salahs left today
                        if [ $current_hr -gt $prayer_hr ]; then
                            if [ $i -eq 6 ]; then
                                # first prayer of next day
                                read -r tyme
                                if [[ $line =~ [A-Z].* ]]; then
                                    read -r tyme
                                else
                                    read -r tyme
                                    read -r tyme
                                fi

                                echo $tyme
                            fi
                        fi
                    done
                fi
            else
                for i in {1..5}
                do
                    read -r tyme
                done
            fi
        done < .times
    fi

    if [ "$2" == 'today' ]
    then
        while IFS= read -r line
        do
            if [[ $line =~ [A-Z].* ]]; then
                # echo "$line"
                if [[ $line == $mon_day ]]; then
                    echo "$line"
                    for i in {1..5}
                    do
                        read -r tyme
                        echo -n "$tyme"
                        echo -n " | "
                    done
                    read -r tyme
                    echo -n "$tyme"
                    echo ""
                    break
                fi
            else
                for i in {1..5}
                do
                    read -r tyme
                done
            fi
        done < .times
    fi

    if [ "$2" == 'd' ]
    then
        if [ $# == 2 ]; then
            ./salah.sh -h
        fi

        # validate $2
        if [[ ("$3" -lt 1) || ("$3" -gt 31) ]]; then
            echo "Error: invalid day of month"
        else
            # day = mon_day="$(date '+%d')"
            # echo -n "Target day: "
            # echo $3
            while IFS= read -r line
            do
                if [[ $line =~ [A-Z].* ]]; then
                    # echo "$line"
                    # Test if value at the end equals the day provided
                    day_read=$(echo $line | awk '{print $2}')
                    # echo $day_read
                    if [[ ${day_read#0} -eq $3 ]]; then
                        echo "$line"
                        for i in {1..5}
                        do
                            read -r tyme
                            echo -n "$tyme"
                            echo -n " | "
                        done
                        read -r tyme
                        echo -n "$tyme"
                        echo ""
                        break
                    fi
                else
                    for i in {1..5}
                    do
                        read -r tyme
                    done
                fi
            done < .times
        fi

    fi
fi
