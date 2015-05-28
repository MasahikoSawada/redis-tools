#!/bin/bash

PORT_PREFIX=700
REDISCONF=redis.conf

function usage()
{
    echo "Usage :"
    echo "    sh cluster-setup.sh <directory name> <number of servers>"
    echo "    sh cluster-setup.sh <number of servers>"
    echo "    If first argment is single-numeric, we select 2nd syntax"
    exit 1
}

if [[ "${1}" =~ .*help ]];then
    usage
fi

WORK=$1
NODES=$2

if [[ "${1}" =~ [0-9][0-9]* ]];then
    WORK=test
    NODES=$1
elif [ "${2}" = "" ];then
    echo "Must be specified the number of servers \$2"
    exit 1
elif [ "${2}" -le 0 ];then
    echo "Invalid number of redis server : $1"
    exit 1
fi

# Stop cluster servers
sh ./cluster-stop.sh

# Clean up directories
rm -rf ./${WORK}
mkdir ./${WORK}

# Crate directories
for i in `seq 1 ${NODES}`
do
    PORT=${PORT_PREFIX}${i}
    DIR=${WORK}/${PORT}
    mkdir ./${DIR}
done

HOSTLIST=""
for i in `seq 1 ${NODES}`
do
    PORT=${PORT_PREFIX}${i}
    DIR=${WORK}/${PORT}

    cat <<EOF > ./${DIR}/${REDISCONF}
port ${PORT_PREFIX}${i}
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes
maxmemory 16MB
logfile ${PORT}.log
EOF

    cd ./${DIR}
    redis-server ${REDISCONF}
    cd ../..

    HOSTLIST=${HOSTLIST}" 127.0.0.1:${PORT_PREFIX}${i}"
done

ruby ./redis-trib.rb create ${HOSTLIST}