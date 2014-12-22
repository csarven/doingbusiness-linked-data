#!/bin/bash
#doingbusiness.preprocessing.sh

#TODO: find other pattern
files=../data/*.2*.csv;

for file in $files ; do

	if [ ! -f $file ]; then
    	>&2 echo "Error: the the following path and/or file does not exist: $file. Make sure to run previous workflow step first (doingbusiness.get.sh).";
    	exit 1;
	fi
	head -n 2 $file | tr '[:upper:]' '[:lower:]' | sed "1d" > $file.temp.refined.csv;

	tail -n+3 $file >> $file.temp.refined.csv;

	sed "1s/^/economy,refPeriod,rank-overall,dtf-overall,/" $file.temp.refined.csv > $file.temp2.refined.csv;

	rm $file.temp.refined.csv;

	filename=$(basename $file);
	filename="${filename%.*}"

	echo "Refining $filename...";
	sed "1s/(//g" $file.temp2.refined.csv | sed "1s/)//g" | sed "1s/ number//g" | sed "1s/ /-/g"  | sed "1s/time-//g" | sed "1s/%/in-percent/g" | sed 's/"//g' | sed 's/,,//g' | sed 's/\.\.//g' | sed '1s/[0-9]//g' | sed "1s/--\.//g" | sed '1s/--//g' | sed '1s/outcomeas-piecemeal-sale-andas-going-concern/outcome/g' | sed "1s/'//g" | sed '1s/to-export-days/days-to-export/' | sed '1s/to-import-days/days-to-import/' | sed "1s/us\\$/in-us-dollar/g" | sed "1s/deflated-us\\$/in-deflated-us-dollar/g" | sed "1s/min\./minimum/" >> ../data/$filename.refined.csv

	rm $file.temp2.refined.csv;
done

