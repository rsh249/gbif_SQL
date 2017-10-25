#!/bin/bash   
##This software was written by:
#####Robert S. Harbert#########
#####rharbert@amnh.org#########
##Direct all questions here####


##SETUP SCRIPT       


pwd=$(echo $PBS_O_WORKDIR) #if working under PBS Scheduler
#pwd=$(echo $PWD) #if working directly

us=$1
pa=$2
h=$3
db=$4


#Check for downloaded GBIF archive. It should be placed in the same directory as SETUP.sh. IF does not exist then exit with message for user.



job_id=$(cat $pwd/download_id.txt) #Check the download_id.txt file for the job ID. Use this for path to zip directory
FILE="$pwd/$job_id.zip"
#FILE="~/array1/gbif_HPC/$job_id.zip"
echo $FILE


#if [ -e $FILE ];
#then
#   echo "File $FILE exists. Proceed with setup"
#else
#   echo "File $FILE does not exist."
#	exit
#fi



##Build SQL tables first, then unzip and process data files
#CREATE DB
#mysql -u $us -p$pa -h$h -e "create database IF NOT EXISTS $db;"

#BUILD FAST TABLE
mysql -u $us -p$pa -h$h $db < $pwd/bin/blank_table.sql

#BUILD COMPLETE TABLE
mysql -u $us -p$pa -h$h $db < $pwd/bin/gbif_mastercsv.sql



#unzip GBIF archive:
#if [ -e "$pwd/unziparchive" ] ; then
#	rm -R "$pwd/unziparchive"
#	mkdir "$pwd/unziparchive"
#fi
#unzip $FILE -d $pwd/unziparchive >> /dev/null

#mkdir "$pwd/unziparchive/repos"
#RUN split script ON GBIF DOWNLOAD
#perl $pwd/bin/gbif_split.pl $pwd/unziparchive $us $pa $h ##Pass sql username and password to perl
#exit;

load=$pwd/load.bat
fast=$pwd/loadfast.bat
#if [ -f $load ];
#then
#	rm $load
#fi
#if [ -f $fast ];
#then
#	rm $fast
#fi

perl $pwd/bin/write_sql_batch.pl unziparchive/repos $db;

mysql -u$us -p$pa -h$h < $load
mysql -u$us -p$pa -h$h < $fast
exit

#if [ -f $pwd/wget-log ];
#then
#	rm $pwd/wget-log
#fi

#may not be necessary
#mysql -u $us -p$pa -h$h -e div_ext "OPTIMIZE div_base;"
#mysql -u $us -p$pa -h$h -e div_ext "OPTIMIZE gbif_master;"







