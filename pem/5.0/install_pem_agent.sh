#!/bin/bash

PEM_SERVER_IP=''
CONTAINER_NAME=`hostname`
AGENT_ID=`hostname -i | cut -f4 -d '.'`

# install agent
yum -y install pem-agent

# create config file
cp /usr/pem-5.0/etc/agent.cfg.sample /usr/pem-5.0/etc/agent.cfg
sed -i "s/pem_host=.*/pem_host=${PEM_SERVER_IP}/" /usr/pem-5.0/etc/agent.cfg
sed -i "s/pem_port=.*/pem_port=5432/" /usr/pem-5.0/etc/agent.cfg
sed -i "s/agent_id=.*/agent_id=${AGENT_ID}/" /usr/pem-5.0/etc/agent.cfg

#register agent
 /usr/pem-5.0/bin/pemagent --register-agent --pem-server ${PEM_SERVER_IP} --pem-user enterprisedb --display-name ${CONTAINER_NAME}

# start agent
service pemagent start