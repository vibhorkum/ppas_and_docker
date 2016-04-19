#!/bin/bash

#### TODO: Most of this stuff doesn't actually work.
#### The individual commands work when signed into the container.
#### Currently working on getting the script to run all the way through.

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing xDB cluster ====\n\e[0m"
  docker rm -f xdb_{oracle,postgres}
  exit 0
fi

printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
C_NAME="xdb_oracle"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v ${PWD}:/xdb_demo -v /Users/${USER}/Desktop:/Desktop --hostname=xdb_oracle --detach=true --name=xdb_oracle wnameless/oracle-xe-11g:latest
ORA_IP=`docker exec -it ${C_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t ${C_NAME} bash --login -c "sqlplus system/oracle < /xdb_demo/oracle_files/load_oracle_test_data.sql"
printf "\e[0;33m${C_NAME} => ${ORA_IP}\n\e[0m"

IMAGE_NAME="xdb51:5.1.9"
XDB_VERSION="5.1"
C_NAME="xdb_postgres"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v ${PWD}:/xdb_demo -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
docker exec -t ${C_NAME} bash --login -c "cp /xdb_demo/oracle_files/ojdbc6.jar /usr/ppas-xdb-${XDB_VERSION}/lib/jdbc/ojdbc6.jar"
sleep 5
docker exec -t ${C_NAME} bash --login -c "createdb xdb_ctl"
docker exec -t ${C_NAME} bash --login -c "/etc/init.d/edb-xdbpubserver start"
docker exec -t ${C_NAME} bash --login -c "/etc/init.d/edb-xdbsubserver start"

PG_IP=`docker exec -it ${C_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
printf "\e[0;33m${C_NAME} => ${PG_IP}\n\e[0m"

ENCRYPTED_ORA_PASS="deIuKoLKPi4="

printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
docker exec -t xdb_postgres bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -addpubdb -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -dbtype oracle -dbhost ${ORA_IP} -dbuser system -dbpassword ${ENCRYPTED_ORA_PASS} -database XE -dbport 1521"
docker exec -t xdb_postgres bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -createpub xdbtest -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables SYSTEM.TEST_DATA -repgrouptype S"
docker exec -t xdb_postgres bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -addsubdb -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf -dbtype enterprisedb -dbhost ${PG_IP} -dbuser enterprisedb -dbpassword \`cat /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf | grep pass | cut -f2- -d'='\` -database edb -dbport 5432"
docker exec -t xdb_postgres bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -createsub xdbsub -subsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf -subdbid 1 -pubsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -pubname xdbtest" # TODO: This command doesn't actually work
docker exec -t xdb_postgres bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -dosnapshot xdbsub -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf"

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
docker exec -it xdb_postgres bash --login -c "psql -c \"SELECT * FROM system.test_data WHERE id = 10000\" edb"
docker exec -it xdb_oracle bash --login -c "sqlplus system/oracle \"UPDATE test_data SET FIRST_NAME = 'myfirstname' WHERE id = 10000\""
sleep 5
docker exec -t xdb_postgres bash --login -c "java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -dosynchronize xdbsub -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf"
sleep 10

docker exec -it xdb_oracle bash --login -c "sqlplus system/oracle \"SELECT * FROM test_data WHERE id = 10000\""
docker exec -it xdb_postgres bash --login -c "psql -c \"SELECT * FROM system.test_data WHERE id = 10000\" edb"
