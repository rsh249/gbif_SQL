#!/bin/bash   
##SETUP FILE       

#Prompt the user for SQL login info from the command line
pwd=$(echo $PWD)




echo -n "Enter your sql user name and press [ENTER]: "
read us
echo -n "Enter your sql password and press [ENTER]: "
read pa
echo -n "Enter the hostname or IP for sql server (usually localhost) [ENTER]:"
read h
echo -n "Enter your database name [ENTER]: "
read db



#Check for downloaded GBIF archive. It should be placed in the same directory as SETUP.sh. IF does not exist then exit with message for user.



job_id=$(cat $pwd/download_id.txt) #Check the download_id.txt file for the job ID. Use this for path to zip directory
FILE="$pwd/$job_id.zip"

if [ -f $FILE ];
then
   echo "File $FILE exists. Proceed with setup"
else
   echo "File $FILE does not exist."
	exit
fi



##Build SQL tables first, then unzip and process data files
#CREATE DB
mysql -u $us -p$pa -h$h -e "create database IF NOT EXISTS $db;"

#BUILD FAST TABLE
mysql -u $us -p$pa -h$h $db < $pwd/bin/blank_table.sql

#BUILD COMPLETE TABLE
mysql -u $us -p$pa -h$h $db < $pwd/bin/gbif_mastercsv.sql

##WORKS THROUGH THIS POINT AS OF JANUARY 23, 2017


#unzip GBIF archive:
if [ -e "$pwd/unziparchive" ] ; then
	rm -R "$pwd/unziparchive"
fi
unzip $pwd/*.zip -d $pwd/unziparchive >> /dev/null

#RUN PERL SCRIPT ON GBIF DOWNLOAD
perl $pwd/bin/gbif_split.pl 'unziparchive' $us $pa $h ##Pass sql username and password to perl

if [ -f $pwd/update.bat ];
then
	rm $pwd/update.bat
fi
if [ -f $pwd/updatefast.bat ];
then
	rm $pwd/updatefast.bat
fi

perl $pwd/bin/write_sql_batch.pl 'unziparchive/repos' $db

mysql -u$us -p$pa -h$h < $pwd/load.bat
mysql -u$us -p$pa -h$h < $pwd/loadfast.bat


if [ -f $pwd/wget-log ];
then
	rm $pwd/wget-log
fi

#may not be necessary
#mysql -u $us -p$pa -h$h -e div_ext "OPTIMIZE div_base;"
#mysql -u $us -p$pa -h$h -e div_ext "OPTIMIZE gbif_master;"







