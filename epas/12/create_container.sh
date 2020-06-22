#!/bin/bash

NODE_TYPE=$1
NODE_NAME=$2
MASTER_HOST=$3
MASTER_PORT=$4

function usage()
{
    echo "$0 NODE_TYPE NODE_NAME MASTER_HOST MASTER_PORT"
    exit 1
}

if [[ -z ${NODE_TYPE} ]]
then
    echo "ERROR: node type is needed for script"
    usage
fi
if [[ -z ${NODE_NAME} ]]
then
    echo "ERROR: node name is needed for script"
    usage
fi

if [[ "${NODE_TYPE}" = "master" ]]
then
    docker create -e "NODE_TYPE=master" \
          --name=${NODE_NAME} \
          --hostname=${NODE_NAME} epas:12 \
          && docker start ${NODE_NAME} \
          && docker logs ${NODE_NAME}
fi

if [[ "${NODE_TYPE}" = "standby" ]]
then
    if [[ -z ${MASTER_HOST} ]]
    then
        echo "ERROR: master host is needed for standby"
        usage
        exit 1
    fi
    if [[ -z ${MASTER_PORT} ]]
    then
        echo "ERROR: master port is needed for standby"
        usage
        exit 1
    fi

    docker create -e "NODE_TYPE=${NODE_TYPE}" \
        -e "MASTER_HOST=${MASTER_HOST}" -e "MASTER_PORT=${MASTER_PORT}" \
        --name=${NODE_NAME} \
        --hostname=${NODE_NAME} epas:12 \
        && docker start ${NODE_NAME} \
        && docker logs -f ${NODE_NAME}
fi
