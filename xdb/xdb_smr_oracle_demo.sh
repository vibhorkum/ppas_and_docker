#!/bin/bash

#### NOTE: This is designed only to work with XDB 6.0 and later.
#### This has not been tested for XDB 5.1.x

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing xDB cluster ====\n\e[0m"
  docker rm -f xdb_{oracle,postgres}
  exit 0
fi

printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
O_NAME="xdb_oracle"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v ${PWD}:/xdb_demo -v /Users/${USER}/Desktop:/Desktop --hostname=xdb_oracle --detach=true --name=xdb_oracle wnameless/oracle-xe-11g:latest
ORA_IP=`docker exec -it ${O_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t ${O_NAME} bash --login -c "echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> ~/.profile"
docker exec -t ${O_NAME} bash --login -c "echo 'export PATH=\$ORACLE_HOME/bin:\$PATH' >> ~/.profile"
docker exec -t ${O_NAME} bash --login -c "echo 'export ORACLE_SID=XE' >> ~/.profile"
printf "\e[0;33m${O_NAME} => ${ORA_IP}\n\e[0m"

IMAGE_NAME="xdb6:latest"
XDB_VERSION="6.0"
XDB_PATH="/usr/ppas-xdb-${XDB_VERSION}"
P_NAME="xdb_postgres"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v ${PWD}:/xdb_demo -v /Users/${USER}/Desktop:/Desktop --hostname=${P_NAME} --detach=true --name=${P_NAME} ${IMAGE_NAME}
PG_IP=`docker exec -it ${P_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
printf "\e[0;33m${P_NAME} => ${PG_IP}\n\e[0m"

printf "\e[0;33m==== Preparing data and services ====\n\e[0m"
docker exec -t ${O_NAME} bash --login -c "sleep 30" # Make sure Oracle server has actually spun up within the container, if it hasn't already
docker exec -t ${O_NAME} bash --login -c "sqlplus -S system/oracle < /xdb_demo/oracle_files/load_oracle_test_data.sql"

docker exec -t ${P_NAME} bash --login -c "cp /xdb_demo/oracle_files/ojdbc6.jar ${XDB_PATH}/lib/jdbc/ojdbc6.jar"
docker exec -t ${P_NAME} bash --login -c "/etc/init.d/edb-xdbpubserver start"
docker exec -t ${P_NAME} bash --login -c "/etc/init.d/edb-xdbsubserver start"

ENCRYPTED_ORA_PASS="deIuKoLKPi4=" # Plaintext password is "oracle"

printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -addpubdb -repsvrfile ${XDB_PATH}/etc/xdb_repsvrfile.conf -dbtype oracle -dbhost ${ORA_IP} -dbuser system -dbpassword ${ENCRYPTED_ORA_PASS} -database XE -dbport 1521"
docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -createpub xdbtest -repsvrfile ${XDB_PATH}/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables SYSTEM.TEST_DATA -repgrouptype S"
docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -addsubdb -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf -dbtype enterprisedb -dbhost ${PG_IP} -dbuser enterprisedb -dbpassword \`cat ${XDB_PATH}/etc/xdb_subsvrfile.conf | grep pass | cut -f2- -d'='\` -database edb -dbport 5432 -repgrouptype S"
SUBDB_ID=`docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -printsubdbids -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf" | tail -n 1 | awk '{ printf("%d",$1) }'` # repcli does something funky with the output, so pipe it through awk to clean it up
docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -createsub xdbsub -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf -subdbid ${SUBDB_ID} -pubsvrfile ${XDB_PATH}/etc/xdb_repsvrfile.conf -pubname xdbtest"
docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -dosnapshot xdbsub -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf"

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
docker exec -it xdb_oracle bash --login -c "echo \"SELECT * FROM test_data WHERE id = 10000;\" | sqlplus -S system/oracle"
docker exec -it xdb_postgres bash --login -c "psql -c \"SELECT * FROM system.test_data WHERE id = 10000\" edb"
docker exec -it xdb_oracle bash --login -c "echo \"update test_data set first_name = 'my_name_changed' where id = 10000;\" | sqlplus -S system/oracle"
sleep 5
docker exec -t xdb_postgres bash --login -c "java -jar ${XDB_PATH}/bin/edb-repcli.jar -dosynchronize xdbsub -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf"
sleep 10

docker exec -it xdb_oracle bash --login -c "echo \"SELECT * FROM test_data WHERE id = 10000;\" | sqlplus -S system/oracle"
docker exec -it xdb_postgres bash --login -c "psql -c \"SELECT * FROM system.test_data WHERE id = 10000\" edb"
