#!/bin/bash

IMAGE_NAME="xdb:5"

if [[ ${1} == 'destroy' ]]
then
  for ((i=1;i<6;i++))
  do
    docker rm -f xdb${i}
  done
  exit 0
fi

if [[ ${1} == 'image' ]]
then
  # Warn user before building image--give them a chance to stop and go set the passwords
  echo "Building Image -- be sure to set passwords as necessary (sleeping for 10sec so you can abort)"
	sleep 10

  # Create Image
  PWD=`pwd`
  cd ${PWD}/centos-6.6/9.1/5.1.1/
  docker build --no-cache -t "${IMAGE_NAME}" .
	cd ${PWD}
fi

OTHER_MASTER_IPS=''
for ((i=1;i<6;i++))
do
  C_NAME="xdb${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
  IP=`docker exec -it ${C_NAME} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
	echo "${C_NAME} => ${IP}"
	if [[ ${i} -gt 1 ]]
	then
	  OTHER_MASTER_IPS="${OTHER_MASTER_IPS} ${IP}"
  fi
done

echo SETTING UP MASTER
# Load tables/data
docker exec -t xdb1 sed -i "s/^export OTHER_MASTER_IPS.*/export OTHER_MASTER_IPS='${OTHER_MASTER_IPS}'/" /usr/ppas-xdb-5.1/bin/build_xdb_publication.sh
docker exec -t xdb1 bash --login -c "/usr/ppas-xdb-5.1/bin/build_xdb_publication.sh"

echo DONE, VERIFYING REPLICATION
# Verify replication works
for ((i=2;i<6;i++))
do
  docker exec -it xdb${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done
docker exec -t xdb1 bash --login -c "psql -c \"UPDATE pgbench_accounts SET filler=md5(random()::text) WHERE aid = 1\" edb"
sleep 10
for ((i=2;i<6;i++))
do
  docker exec -it xdb${i} bash --login -c "psql -c \"SELECT * FROM pgbench_accounts WHERE aid = 1\" edb"
done

# Check uptime
docker exec -it xdb1 java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -uptime
