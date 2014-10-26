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

filename=$ndatadir"/"$coursesfile

while read -r line
do
	url=$line
	echo "Updating: "$url
	ruby "$fetcher" "$url" "$calendarsdir" parseit # parse it now

done < "$filename"