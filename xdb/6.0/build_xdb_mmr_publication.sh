#!/bin/bash

PUBSVR_IP=`hostname -i`

# Make these IPs available for other scripts
export MDN_IP=`hostname -i`
export OTHER_MASTER_IPS=''

XDB_HOME="xdbinstalldir_placeholder"
XDB_PORT="xdbdbport_placeholder"

# Start xDB
rm -f /var/run/edb/xdbpubserver/edb-xdbpubserver.pid
rm -f /var/run/edb-xdbpubserver/edb-xdbpubserver.pid
service edb-xdbpubserver start

# Load data into MDN
pgbench -h ${MDN_IP} -i edb
# psql -h ${MDN_IP} -c "ALTER TABLE pgbench_history add primary key (tid,bid,aid,delta,mtime)" edb

# Build xDB replication infrastructure
java -jar ${XDB_HOME}/bin/edb-repcli.jar -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -uptime
java -jar ${XDB_HOME}/bin/edb-repcli.jar -addpubdb -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -dbtype enterprisedb -dbhost ${MDN_IP} -dbuser enterprisedb -dbpassword `cat ${XDB_HOME}/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -nodepriority 1 -dbport ${XDB_PORT} -changesetlogmode W
java -jar ${XDB_HOME}/bin/edb-repcli.jar -createpub xdbtest -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables public.pgbench_accounts public.pgbench_branches public.pgbench_tellers -repgrouptype M -standbyconflictresolution 1:E 2:E 3:E

# Add other masters
for i in ${OTHER_MASTER_IPS}
do
    java -jar ${XDB_HOME}/bin/edb-repcli.jar -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -addpubdb -dbtype enterprisedb -dbhost ${i} -dbuser enterprisedb -dbpassword `cat ${XDB_HOME}/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -dbport  ${XDB_PORT} -initialsnapshot -replicatepubschema true -changesetlogmode W
done

# Create Schedule
java -jar ${XDB_HOME}/bin/edb-repcli.jar -repsvrfile ${XDB_HOME}/etc/xdb_repsvrfile.conf -confschedulemmr basic_schedule -pubname xdbtest -realtime 5
