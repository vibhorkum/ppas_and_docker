#!/bin/bash

# To be run on Master/Publication Database

PUB_IP=`hostname -i`
SUB_IP=$1

XDB_HOME="xdbinstalldir_placeholder"
XDB_PORT="xdbdbport_placeholder"

# Start publication and subscription servers
service edb-xdbpubserver start
service edb-xdbsubserver start

# Load data into Publication database
pgbench -i edb

# Build xDB replication infrastructure
java -jar ${XDB_HOME}/bin/edb-repcli.jar -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -uptime

# Create publication
sed -i "s/127.0.0.1/${PUB_IP}/" ${XDB_HOME}/etc/xdb_repsvrfile.conf
java -jar ${XDB_HOME}/bin/edb-repcli.jar -addpubdb -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -dbtype enterprisedb -dbhost ${PUB_IP} -dbuser enterprisedb -dbpassword `cat ${XDB_HOME}/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype s -dbport ${XDB_PORT}
java -jar ${XDB_HOME}/bin/edb-repcli.jar -createpub xdbtest -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables public.pgbench_accounts public.pgbench_branches public.pgbench_tellers -repgrouptype S

# Create subscription
sed -i "s/127.0.0.1/${PUB_IP}/" ${XDB_HOME}/etc/xdb_subsvrfile.conf
java -jar ${XDB_HOME}/bin/edb-repcli.jar -addsubdb -repsvrfile ${XDB_HOME}/etc/xdb_subsvrfile.conf -dbtype enterprisedb -dbhost ${SUB_IP} -dbuser enterprisedb -dbpassword `cat ${XDB_HOME}/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -dbport ${XDB_PORT}
java -jar ${XDB_HOME}/bin/edb-repcli.jar -createsub xdbsub -subsvrfile ${XDB_HOME}/etc/xdb_subsvrfile.conf -subdbid `java -jar /usr/ppas-xdb-6.0/bin/edb-repcli.jar -printsubdbids -repsvrfile /usr/ppas-xdb-6.0/etc/xdb_subsvrfile.conf | tail -n 1` -pubsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -pubname xdbtest

# Perform snapshot
java -jar ${XDB_HOME}/bin/edb-repcli.jar -dosnapshot xdbsub -repsvrfile ${XDB_HOME}/etc/xdb_subsvrfile.conf
