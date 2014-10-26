#!/bin/sh

######## SET ONLY THIS ONE ########
calendarsdir="../calendars"
ndatadir="../ndata"
###################################

url=$1
coursesfile="courses.narigas"

rubiersdir="rubiers"
fetcher=$rubiersdir"/icalendarfetcher.rb"
parser=$rubiersdir"/icalendarparser.rb"

if [ $url == "" ]; then
	echo "Syntax... "$0" CALENDAR_URL"
	exit 1
else
	ruby "$fetcher" "$url" "$calendarsdir" parseit # parse it now
	
	# if all is ok, add this url to calendars to update if not present yet
	if [ $? == '0' ]; then
	
		filename=$ndatadir"/"$coursesfile
		ispresent=0
		
		while read -r line
		do
   			currurl=$line
    		echo "Url read from file:" $currurl
    		if [ $currurl == $url ]; then
    			ispresent=1
    		fi
		done < "$filename"
		
		if [ $ispresent -eq 0 ]; then
			echo "$url" >> "$filename"
		fi
		
		echo "OK: everything ok!"
	else
		echo "KO: something went wrong!"
	fi
fi