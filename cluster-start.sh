#!/bin/sh

REDISCONF=redis.conf

function usage()
{
    echo "Usage :"
    echo "    sh cluster-start.sh [<directory name>]"
    echo "    Default directory name is \"test\""
    exit 1
}

if [[ "${1}" =~ .*help ]];then
    usage
fi
WORK=${1:-test}

for node in `ls -1 ${WORK}`
do
    DIR=${WORK}/${node}
    cd ./${DIR}
    redis-server ${REDISCONF}
    cd ../..
done
