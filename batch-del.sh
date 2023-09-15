#!/bin/bash

# Parse args
if [[ $# != [1] ]] ; then
        echo "Usage: $0 \"<url with jobs to delete>\" (with quotes)"
exit 1
fi

wget "$1" -O /tmp/job_ids 
job_ids=`grep jobid /tmp/job_ids |awk -F 'data-jobid="' '{print $2}' |cut -d'"' -f1 |xargs`
host=`echo $1 | awk -F"/" '{print $3}'`

if [ -z "$job_ids" ]
then
echo "No jobs to delete"
exit 1
fi

read -p "WARNING !!! : PROCEEDING WILL DELETE ALL JOBS FROM URL: $1 

CONFIRM DELETING ALL JOBS FROM URL ABOVE ? y/N" resp

case $resp in 
        [yY] ) for jobs in $job_ids; do openqa-client --host $host jobs/$jobs delete; done;;
        * ) exit;;
esac


exit 0
