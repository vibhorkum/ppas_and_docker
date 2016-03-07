#!/bin/bash

# To be run on Master/Publication Database

PUB_IP=`hostname -i`
SUB_IP=$1

# Create xDB Control Database
createdb xdb_pub

# Start publication and subscription servers
service edb-xdbpubserver start
service edb-xdbsubserver start

# Load data into Publication database
pgbench -i -F 10 -s 10 edb

# Build xDB replication infrastructure
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -uptime

# Create publication
sed -i "s/127.0.0.1/${PUB_IP}/" /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -addpubdb -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -dbtype enterprisedb -dbhost ${PUB_IP} -dbuser enterprisedb -dbpassword `cat /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype s -dbport 5432
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -createpub xdbtest -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables public.pgbench_accounts public.pgbench_branches public.pgbench_tellers -repgrouptype S

# Create subscription
sed -i "s/127.0.0.1/${PUB_IP}/" /usr/ppas-xdb-5.1/etc/xdb_subsvrfile.conf
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -addsubdb -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_subsvrfile.conf -dbtype enterprisedb -dbhost ${SUB_IP} -dbuser enterprisedb -dbpassword `cat /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -dbport 5432
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -createsub xdbsub -subsvrfile /usr/ppas-xdb-5.1/etc/xdb_subsvrfile.conf -subdbid 1 -pubsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -pubname xdbtest

# Perform snapshot
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -dosnapshot xdbsub -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_subsvrfile.conf
