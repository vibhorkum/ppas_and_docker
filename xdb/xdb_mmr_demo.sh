#!/bin/bash

# IMAGE_NAME="xdb51:latest"
# XDB_VERSION="5.1"
IMAGE_NAME="xdb6:6.0.0"
XDB_VERSION="6.0"
num_nodes=4

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing xDB cluster ====\n\e[0m"
  for ((i=1;i<${num_nodes};i++))
  do
    docker rm -f xdb${i}
  done
  exit 0
fi

if [[ ${1} == 'image' ]]
then
  # Create Image
	printf "\e[0;33m==== Building new image for xDB cluster ====\n\e[0m"
  PWD=`pwd`
  cd ${PWD}/${XDB_VERSION}
  docker build --no-cache --build-arg EDBUSERNAME=${EDBUSERNAME} --build-arg EDBPASSWORD=${EDBPASSWORD} --build-arg INSTALLER_FILENAME=${INSTALLER_FILENAME} -t ${IMAGE_NAME} .
  cd ${PWD}
fi

OTHER_MASTER_IPS=''
printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
for ((i=1;i<${num_nodes};i++))
do
  C_NAME="xdb${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
  IP=`docker exec -it ${C_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
  printf "\e[0;33m${C_NAME} => ${IP}\n\e[0m"
  if [[ ${i} -gt 1 ]]
  then
    OTHER_MASTER_IPS="${OTHER_MASTER_IPS} ${IP}"
  fi
done

printf "\e[0;33m>>> SETTING UP MASTER DATABASE\n\e[0m"
# Load tables/data
docker exec -t xdb1 sed -i "s/^export OTHER_MASTER_IPS.*/export OTHER_MASTER_IPS='${OTHER_MASTER_IPS}'/" /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh

printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
docker exec -t xdb1 bash --login -c "/usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh"

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
# Verify replication works
for ((i=2;i<${num_nodes};i++))
do
  docker exec -it xdb${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done
docker exec -t xdb1 bash --login -c "psql -c \"UPDATE pgbench_accounts SET filler=md5(random()::text) WHERE aid = 1\" edb"
sleep 10
for ((i=2;i<${num_nodes};i++))
do
  docker exec -it xdb${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done

printf "\e[0;33m>>> xDB Status\n\e[0m"
# Check uptime
docker exec -it xdb1 java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -uptime
