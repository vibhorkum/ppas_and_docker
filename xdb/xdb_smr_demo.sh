#!/bin/bash

C_SUFFIX=${1}
if [[ ${C_SUFFIX} -eq 6 ]]
then
  XDB_VERSION="6.0"
  IMAGE_NAME="xdb6:latest"
else
  XDB_VERSION="5.1"
  IMAGE_NAME="xdb51:latest"
fi

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing xDB cluster ====\n\e[0m"
  docker rm -f xdb_smr_master
  docker rm -f xdb_smr_slave
  exit 0
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
docker exec -t xdb_smr_master bash --login -c "/usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_smr_publication.sh ${SUB_IP}"

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
for i in master slave
do
  docker exec -it xdb_smr_${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done

docker exec -it xdb_smr_master bash --login -c "psql -c \"UPDATE pgbench_accounts SET filler = md5(random()) WHERE aid = 1\" edb"
sleep 5
docker exec -t xdb_smr_master bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -dosynchronize xdbsub -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf"
sleep 10

for i in master slave
do
  docker exec -it xdb_smr_${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done
