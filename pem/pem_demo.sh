#!/bin/bash

IMAGE_NAME="pem:5"
EDB_LOGIN=''
EDB_PASSWORD=''

if [[ ${1} == 'destroy' ]]
then
  for i in server agent1 agent2
  do
    docker rm -f pem-${i}
  done
  exit 0
fi

if [[ "x${EDB_LOGIN}" == "x" || "x${EDB_PASSWORD}" == "x" ]]
then
  echo "Please fill in your EDB login and password in ${0}"
	exit 1
fi

if [[ ${1} == 'image' ]]
then
  # Warn user before building image--give them a chance to stop and go set the passwords
  echo "Building Image -- be sure to set passwords as necessary (sleeping for 10sec so you can abort)"
  sleep 10

  # Create Image
  PWD=`pwd`
  cd ${PWD}/5.0
  docker build -t "${IMAGE_NAME}" .
  cd ${PWD}
fi

# Create Containers
for i in server agent1 agent2
do
  C_NAME="pem-${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
done

# set up PEM Server
docker exec -t pem-server sed -i "s/existing-user.*/existing-user=${EDB_LOGIN}/" /root/pem_install_optionfile
docker exec -t pem-server sed -i "s/existing-password.*/existing-password=${EDB_PASSWORD}/" /root/pem_install_optionfile
docker exec -t pem-server bash --login -c "/root/install_pem_server.sh"

# set up PEM Agents
for i in 1 2
do
  MASTER_IP=`docker exec -it pem-server ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
  docker exec -t pem-agent${i} bash --login -c "/root/install_pem_agent.sh ${MASTER_IP}"
  docker exec -t pem-agent${i} bash --login -c "service pemagent start && tail -f /dev/null" &
done

if [[ `uname` = 'Darwin' ]]
then
  boot2dockerip=`boot2docker ip`;
  port=`docker ps -f name=pem-server | grep 8443 | sed -e 's/.*0.0.0.0:\(.*\)->8443.*/\1/'`
  open https://${boot2dockerip}:${port}/pem
fi
