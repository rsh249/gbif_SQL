#!/bin/bash   

##This software was written by:
#####Robert S. Harbert#########
#####rharbert@amnh.org#########
##Direct all questions here####

##GET DOWNLOAD OF DWCA FROM GBIF

#pwd=$(echo $PBS_O_WORKDIR) #if working under PBS Scheduler
pwd=$(echo $PWD) #if working directly
job_id=$(cat $pwd/download_id.txt)
echo $job_id
echo $pwd


if [ -e "$pwd/wget-log" ]; then
	rm "$pwd/wget-log"
fi

#Set up query to check on job
geta="https://api.gbif.org/v1/occurrence/download/"
getb=$job_id
get="$geta$getb"
#echo $get
#Set up query to GBIF API to get download:
dla="https://api.gbif.org/v1/occurrence/download/request/"
dl=$dla$getb.zip
echo $dl

download=$(wget -b $dl)

echo Come back 2 to 4 hours if downloading entire GBIF dataset from now and check on wget-log...
exit


