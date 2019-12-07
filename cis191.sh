#!/bin/bash
if [ $1 == 'create' ]
then
	mkdir $2
elif [ $1 == 'files' ]
then
  i=0
    for element in "$@" ; do
      if [ $element != $1 -a $element != $2 ]
      then
	if [ $i -eq 0 ]
	then
	  echo $element > $2/.submit;
	else
          echo $element >> $2/.submit;
	fi
	i=1
      fi
    done


elif [ $1 == 'backup' ]
then
	if [ "$#" -eq 1 ]
	then
	  for el in */ ; do  
	   if [ -f $el/.submit ]; then
             #mkdir eniac:~/$el
	     ssh eniac "mkdir -p $el "
	   fi
	    while read -r text; do
		scp $el/$text eniac:~/$el/
            done < $el/.submit; 
	  done
	else
	  ssh eniac "mkdir -p $2 "
	  while read -r text; do
	    if [ -f $2/$text ]; then

	    scp $2/$text eniac:~/$2/

	    else
		echo cannot find $2$text, please redefine files and try again.
		return 1
	    fi
	  done < $2/.submit
	fi

elif [ $1 == 'submit' ]
then
  
  if [ ! -d $2 -o ! -f $2/.submit ]
  then 
    echo $2 has no files to submit
  else 
    ./cis191.sh backup $2
    temp=""
    while read -r text; do
      temp="$temp $text"
    done < $2/.submit;
    ssh eniac "cd $2; turnin -c cis191 -p $2$temp"
  fi


else
	echo unrecognized command
fi
