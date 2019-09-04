#!/bin/bash

# Parse args
if [[ $# != [12] ]] ; then
echo "Usage: $0 <pattern> <logfile> (logfile default is y2log)"
exit 1
fi

# set log file
if [ -z $2 ] ; then 
log=/var/log/YaST2/y2log
else
log=$2
fi

if [ ! -e $log ] ; then
echo "$log does not exist"
exit 1 
fi

while : ; do
    grep $1 $log && match=1	
    if (( match == 1 )) ; then
        PIDS=`ps -ef |egrep -i "yast|installation" |egrep -v "grep|$0" |awk '{print $2}' |xargs`
        kill -SIGSTOP $PIDS
        echo "installer paused. type r to resume when ready (eg after using tty5 to upload logs)."
        read resume
        if [ $resume =  "r" ] ; then
            kill -SIGCONT $PIDS 
	        break
        fi
	sleep 0.5
    fi
done

exit 0
