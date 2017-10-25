#!/bin/bash   


##This software was written by:
#####Robert S. Harbert#########
#####rharbert@amnh.org#########
##Direct all questions here####'

## SCRIPT TO ASK GBIF REQUEST API TO PREPARE A DWCA ZIP FILE FOR DOWNLOAD ##

#pwd=$(echo $PBS_O_WORKDIR) #if working under PBS Scheduler
pwd=$(echo $PWD) #if working directly



## Set up request for download
filter="$pwd/filter.json"
log="$pwd/log.txt"
dl_log="$pwd/download_id.txt";
if [ -e $log ]; then
	rm $log
fi
if [ -e $dl_log ]; then
	rm $dl_log
fi
user=$1
pass=$2

echo -n "Enter your GBIF user name and press [ENTER]: "
read user
echo -n "Enter your GBIF password and press [ENTER]: "
read pass
echo -n "Enter a good email address for notifications and press [ENTER]: "
read address



#rm log.txt

#PREPARE DOWNLOAD WITH ALL GEOREFERENCED RECORDS FROM GBIF. NOTE subsequent regular updates may introduce records that are not georeferenced
jsonreq="{
	\"creator\":\"$user\",
	\"notification_address\":[\"$address\"],
	\"sendNotification\": true,
	\"predicate\":	
	{	
		\"type\":\"and\",
		\"predicates\": 
			[
				{\"type\":\"equals\",\"key\":\"HAS_COORDINATE\",\"value\":\"TRUE\"},
				{\"type\":\"equals\",\"key\":\"HAS_GEOSPATIAL_ISSUE\",\"value\":\"FALSE\"}
			]
	}
	}"

#{\"type\":\"equals\",\"key\":\"TAXON_KEY\",\"value\":\"2874877\"} ##Add back in for testing smaller datasets

if [ -e $filter ]; then
  echo "File $filter already exists!"
  echo $jsonreq >> $filter
else  
  echo $jsonreq >> $filter
fi

#Uncomment next line to request new download
curl -i --user $user:$pass -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d @filter.json http://api.gbif.org/v1/occurrence/download/request >> $log
rm $filter

#Parse log file for job ID
job_id=$(grep "." $log | tail -1)
echo $job_id

#END. Do not wait for download to return. Set up this way it should email you when GBIF has the zip file prepared.
echo $job_id >> $dl_log
echo WAIT FOR EMAIL CONFIRMATION BEFORE PROCEEDING. PREPARATION OF DOWNLOAD BY GBIF.ORG CAN TAKE SEVERAL HOURS

exit



