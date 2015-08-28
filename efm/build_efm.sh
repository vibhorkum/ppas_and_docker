#!/bin/bash

if [[ ${1} == 'destroy' ]]
then
  for i in master standby witness
  do
    docker rm -f efm-${i}
  done
  exit 0
fi

IMAGE_NAME="efm:5"
if [[ ${1} == 'image' ]]
then
  # Warn user before building image--give them a chance to stop and go set the passwords
  echo "Building Image -- be sure to set passwords as necessary (sleeping for 10sec so you can abort)"
	sleep 10

  # Create Image
  PWD=`pwd`
  cd ${PWD}/2.0/
  docker build --no-cache -t "${IMAGE_NAME}" .
	cd ${PWD}
fi

for i in master standby witness
do
  C_NAME="efm-${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
done

echo SETTING UP MASTER
# Set up master
docker exec -it efm-master bash --login -c "/usr/efm-2.0/bin/set_as_master.sh"

echo REGISTERING STANDBY
# Register standby
STANDBY_IP=`docker exec -it efm-standby ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t efm-master /usr/efm-2.0/bin/efm add-node efm ${STANDBY_IP} 1

echo SETTING UP STANDBY
# Register standby
# Set up standby
MASTER_IP=`docker exec -it efm-master ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t efm-standby bash --login -c "echo ${MASTER_IP}:5430 >> /etc/efm-2.0/efm.nodes"
docker exec -t efm-standby bash --login -c "/usr/efm-2.0/bin/set_as_standby.sh ${MASTER_IP}"

echo REGISTERING WITNESS
# Register witness
WITNESS_IP=`docker exec -it efm-witness ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t efm-master /usr/efm-2.0/bin/efm add-node efm ${WITNESS_IP} 1

echo SETTING UP WITNESS
# Set up witness
docker exec -t efm-witness bash --login -c "echo ${MASTER_IP}:5430 ${STANDBY_IP}:5430 >> /etc/efm-2.0/efm.nodes"
docker exec -t efm-witness /usr/efm-2.0/bin/set_as_witness.sh

# Show status
docker exec -it efm-master /usr/efm-2.0/bin/efm cluster-status efm
