#!/bin/bash

PEM_SERVER_IP=${1}

if [ "x${PEM_SERVER_IP}" == "x" ]
then
  echo "USAGE: ${0} <pem_server_ip>"
fi

CONTAINER_NAME=`hostname`
AGENT_ID=`hostname -i | cut -f4 -d '.'`

/tmp/`ls /tmp/ | grep agent | grep run` --mode unattended --pghost ${PEM_SERVER_IP} --pguser enterprisedb --pgpassword abc123 --agent_description ${CONTAINER_NAME} --prefix /usr/pem-5.0

find /usr/pem-5.0/agent/lib -type f | xargs -I% ln -s % /lib64/

service pemagent start