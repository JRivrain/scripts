#!/bin/bash

# Parse args
if [[ $# != [2] ]] ; then
echo "Usage: $0 <Github PR or branch> <url with jobs to clone>"
exit 1
fi

wget "$2" -O /tmp/job_ids
job_ids=`grep jobid /tmp/job_ids |awk -F 'data-jobid="' '{print $2}' |cut -d'"' -f1 |xargs`
PR=$1
webui=`echo $2 | awk -F"/overview" '{print $1}'`

for jobs in $job_ids; do
openqa-clone-custom-git-refspec $PR ${webui}/${jobs}
sleep 1
done

exit 0
