#!/bin/bash


# Parse args
if [[ $# != [2] ]] ; then
echo "Usage: $0 <url to json 1> <url to json 2>"
exit 1
fi

wget $1 -O /tmp/json1
wget $2 -O /tmp/json2
sort /tmp/json1 > /tmp/json1.sorted
sort /tmp/json2 > /tmp/json2.sorted
comm -3 /tmp/json1.sorted /tmp/json2.sorted

exit 0
