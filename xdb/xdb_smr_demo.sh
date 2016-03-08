#!/bin/bash

IMAGE_NAME="xdb51:latest"

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing xDB cluster ====\n\e[0m"
  docker rm -f xdb_smr_master
  docker rm -f xdb_smr_slave
  exit 0
fi

if [[ ${1} == 'image' ]]
then
  # Warn user before building image--give them a chance to stop and go set the passwords
	printf "\e[0;31mBuilding Image -- be sure to set passwords as necessary (sleeping for 10sec so you can abort)\n\e[0m"
  sleep 10

  # Create Image
	printf "\e[0;33m==== Building new image for xDB cluster ====\n\e[0m"
  PWD=`pwd`
  cd ${PWD}/5.1
  docker build --no-cache -t "${IMAGE_NAME}" .
  cd ${PWD}
fi

printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
for i in master slave
do
  C_NAME="xdb_smr_${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
  IP=`docker exec -it ${C_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
  printf "\e[0;33m${C_NAME} => ${IP}\n\e[0m"
done

printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
SUB_IP=`docker exec -it xdb_smr_slave ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t xdb_smr_master bash --login -c "/usr/ppas-xdb-5.1/bin/build_xdb_smr_publication.sh ${SUB_IP}"

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
for i in master slave
do
  docker exec -it xdb_smr_${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done

docker exec -it xdb_smr_master bash --login -c "psql -c \"UPDATE pgbench_accounts SET filler = md5(random()) WHERE aid = 1\" edb"
sleep 5
docker exec -t xdb_smr_master bash --login -c "java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -dosynchronize xdbsub -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_subsvrfile.conf"
sleep 10

for i in master slave
do
  docker exec -it xdb_smr_${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done
