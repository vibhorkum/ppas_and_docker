#!/bin/bash

if [[ "x${1}" == "x" ]]
then
  echo "USAGE: ${0} <xdb_version> [destroy]"
  exit 1
fi

C_SUFFIX=${1}
if [[ ${C_SUFFIX} -eq 6 ]]
then
  XDB_VERSION="6.0"
  IMAGE_NAME="xdb6:latest"
else
  XDB_VERSION="5.1"
  IMAGE_NAME="xdb51:latest"
fi

num_nodes=4
if [[ ${2} == 'destroy' ]]
then
  printf "\e[0;31m==== Destroying existing xDB cluster ====\n\e[0m"
  for ((i=1;i<=${num_nodes};i++))
  do
    docker rm -f xdb${C_SUFFIX}-${i}
  done
  exit 0
fi

OTHER_MASTER_IPS=''
printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
C_NAME="xdb${C_SUFFIX}-1"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
for ((i=2;i<=${num_nodes};i++))
do
  C_NAME="xdb${C_SUFFIX}-${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ppas95:latest
  IP=`docker exec -it ${C_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
  printf "\e[0;33m${C_NAME} => ${IP}\n\e[0m"
  OTHER_MASTER_IPS="${OTHER_MASTER_IPS} ${IP}"
done

if [[ ${XDB_VERSION} == '6.0' ]]
then
  for ((i=1;i<=${num_nodes};i++))
  do
    PGMAJOR=9.5
    docker exec -t xdb${C_SUFFIX}-${i} sed -i "s/^wal_level.*/wal_level = logical/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
    docker exec -t xdb${C_SUFFIX}-${i} sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
    docker exec -t xdb${C_SUFFIX}-${i} sed -i "s/^#track_commit_timestamp.*/track_commit_timestamp = on/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
    docker exec -t xdb${C_SUFFIX}-${i} sh -c "echo \"host replication enterprisedb 0.0.0.0/0 trust\" >> /var/lib/ppas/${PGMAJOR}/data/pg_hba.conf"
    docker exec -t xdb${C_SUFFIX}-${i} service ppas-9.5 restart
  done

  # Uncomment and fill in as needed (file needs to be in the form of "license_key=#####-#####-#####-#####-#####")
  # docker exec -it xdb${C_SUFFIX}-1 java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -registerkey -keyfile /Desktop/xdb_license.key
else
  # Uncomment and fill in as needed (file needs to be in the form of "license_key=#####-#####-#####-#####-#####")
  # docker exec -t xdb${C_SUFFIX}-1 sh -c "cat /Desktop/xdb_license.key >> /etc/edb-repl.conf"
  echo "" # Superflous statement to keep if-else loop working when above line is commented out
fi

printf "\e[0;33m>>> SETTING UP MASTER DATABASE\n\e[0m"
# Load tables/data
docker exec -t xdb${C_SUFFIX}-1 sed -i "s/^export OTHER_MASTER_IPS.*/export OTHER_MASTER_IPS='${OTHER_MASTER_IPS}'/" /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh

printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
docker exec -t xdb${C_SUFFIX}-1 bash --login -c "/usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh"

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
# Verify replication works
for ((i=2;i<=${num_nodes};i++))
do
  docker exec -it xdb${C_SUFFIX}-${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done
docker exec -t xdb${C_SUFFIX}-1 bash --login -c "psql -c \"UPDATE pgbench_accounts SET filler=md5(random()::text) WHERE aid = 1\" edb"
sleep 10
for ((i=2;i<=${num_nodes};i++))
do
  docker exec -it xdb${C_SUFFIX}-${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done

printf "\e[0;33m>>> xDB Status\n\e[0m"
# Check uptime
docker exec -it xdb${C_SUFFIX}-1 java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -uptime
