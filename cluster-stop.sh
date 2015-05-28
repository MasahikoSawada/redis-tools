#!/bin/sh

function usage()
{
    echo "Usage :"
    echo "    sh cluster-stop.sh [<directory name>]"
    echo "    Default directory name is \"test\""
    exit 1
}

if [[ "${1}" =~ .*help ]];then
    usage
fi
WORK=${1:-test}

for port in `ls -1 ${WORK}`
do
    echo $port
    redis-cli -p ${port} shutdown
done
