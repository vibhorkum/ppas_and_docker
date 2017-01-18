#!/bin/bash

PEM_VER=6
NUM_AGENTS=2

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing PEM cluster ====\n\e[0m"
	docker rm -f pem-server
  for ((i=1;i<=${NUM_AGENTS};i++))
  do
    docker rm -f pem-agent${i}
  done
  exit 0
fi

# Create Containers
printf "\e[0;33m==== Building containers for PEM cluster ====\n\e[0m"
printf "\e[0;33m>>> SETTING UP PEM SERVER\n\e[0m"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=pem-server --detach=true --name=pem-server pem${PEM_VER}_server:latest

printf "\e[0;33m>>> SETTING UP PEM AGENTS\n\e[0m"
docker exec pem-server service pemagent start

MASTER_IP=`docker exec -it pem-server ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
for ((i=1;i<=${NUM_AGENTS};i++))
do
  C_NAME="pem-agent${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} pem${PEM_VER}_agent:latest
  if [[ ${PEM_VER} -eq 6 ]]
  then
    docker exec -t pem-agent${i} sed -i "s/%%PEM_SERVER_IP%%/${MASTER_IP}/" /tmp/register_pem_agent.sh
    docker exec -t pem-agent${i} sed -i "s/%%AGENT_NAME%%/pemagent${i}/" /tmp/register_pem_agent.sh
    docker exec -t pem-agent${i} bash --login -c "/tmp/register_pem_agent.sh"
    docker exec pem-agent${i} service pemagent start
  else
    docker exec -t pem-agent${i} bash --login -c "/tmp/install_pem_agent.sh ${MASTER_IP}"
  fi
done

if [[ `uname` = 'Darwin' ]]
then
  printf "\e[0;33m>>> LAUNCHING PEM CONSOLE\n\e[0m"
  dockerip=`docker-machine ip docker-vm`;
  port=`docker ps -f name=pem-server | grep 8443 | sed -e 's/.*0.0.0.0:\(.*\)->8443.*/\1/'`
  open https://${dockerip}:${port}/pem
fi
