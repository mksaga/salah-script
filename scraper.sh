#!/bin/bash
h=0
f=0
e=0
p=0
name=0
for var in "$@"
do
    if [ $var == "-h" ]; then
	h=1
    elif [ $var == "-f" ]; then
	f=1
    elif [ $var == "-e" ]; then
	e=1
    elif [ $var == "-p" ]; then
	p=1
    else
	name=$var
    fi
done
if [ $h -eq 1 ]; then
	echo "scraper.sh usage"
	echo "Usage:  ./scraper.sh [optional flag] [URL]"
	echo "Flags"
	echo "-h -- prints out usage information for this tool"
	echo "-f -- read from a file instead of a website, place filename in place of URL"
	echo "-e -- Only gather emails" 
	echo "-p -- only gather phone numbers"
	echo "Output"
	echo "emails.txt a file of all emails from the source in the format name (at) domain (dot) tld"
	echo "phonenumbers.txt a file of all phonenumbers from the source in the format XXX-XXX-XXXX"
elif [ $f -eq 1 ]; then
	if [ $p -eq 1 ]; then
		cat $name | grep -E -o '(([(\][0-9]{3}[)\][ ]?)|([0-9]{3}[-]))[0-9]{3}[-][0-9]{4}' | sed -r 's/[\(]//' | sed -r 's/\)/\-/' | sed -r 's/[ ]//' > phonenumbers.txt
	fi
	if [ $e -eq 1 ]; then
		cat $name | grep -E -o '[A-Za-z0-9.\]{1,}[@][A-Za-z0-9.\]{1,}[.\][A-Za-z]{1,}' | sed -r 's/@/(at)/' | rev | sed -r 's/[.]/)tod(/' | rev > emails.txt
	fi
	if [ $e -eq 0 -a $p -eq 0 ]; then
		cat $name | grep -E -o '[A-Za-z0-9.\]{1,}[@][A-Za-z0-9.\]{1,}[.\][A-Za-z]{1,}' | sed -r 's/@/(at)/' | rev | sed -r 's/[.]/)tod(/' | rev > emails.txt
		cat $name | grep -E -o '(([(\][0-9]{3}[)\][ ]?)|([0-9]{3}[-]))[0-9]{3}[-][0-9]{4}' | sed -r 's/[\(]//' | sed -r 's/\)/\-/' | sed -r 's/[ ]//' > phonenumbers.txt
	fi	
else
	if [ $p -eq 1 ]; then
		wget -O- $name | grep -E -o '(([(\][0-9]{3}[)\][ ]?)|([0-9]{3}[-]))[0-9]{3}[-][0-9]{4}' | sed -r 's/[\(]//' | sed -r 's/\)/\-/' | sed -r 's/[ ]//' > phonenumbers.txt
	fi
	if [ $e -eq 1 ]; then
		wget -O- $name | grep -E -o '[A-Za-z0-9.\]{1,}[@][A-Za-z0-9.\]{1,}[.\][A-Za-z]{1,}' | sed -r 's/@/(at)/' | rev | sed -r 's/[.]/)tod(/' | rev > emails.txt
	fi
	if [ $e -eq 0 -a $p -eq 0 ]; then
		wget -O- $name | grep -E -o '[A-Za-z0-9.\]{1,}[@][A-Za-z0-9.\]{1,}[.\][A-Za-z]{1,}' | sed -r 's/@/(at)/' | rev | sed -r 's/[.]/)tod(/' | rev > emails.txt
		wget -O- $name | grep -E -o '(([(\][0-9]{3}[)\][ ]?)|([0-9]{3}[-]))[0-9]{3}[-][0-9]{4}' | sed -r 's/[\(]//' | sed -r 's/\)/\-/' | sed -r 's/[ ]//' > phonenumbers.txt
	fi
fi
