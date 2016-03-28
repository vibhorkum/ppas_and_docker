#!/bin/bash

PUBSVR_IP=`hostname -i`

# Make these IPs available for other scripts
export MDN_IP=`hostname -i`
export OTHER_MASTER_IPS=''

# Start xDB
createdb -h ${PUBSVR_IP} xdb_ctl
service edb-xdbpubserver start

# Load data into MDN
pgbench -h ${MDN_IP} -i -F 10 -s 10 edb
# psql -h ${MDN_IP} -c "ALTER TABLE pgbench_history add primary key (tid,bid,aid,delta,mtime)" edb

# Build xDB replication infrastructure
java -jar xdbinstalldir_placeholder/bin/edb-repcli.jar -repsvrfile xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf -uptime
java -jar xdbinstalldir_placeholder/bin/edb-repcli.jar -addpubdb -repsvrfile xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf -dbtype enterprisedb -dbhost ${MDN_IP} -dbuser enterprisedb -dbpassword `cat xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -nodepriority 1 -dbport xdbdbport_placeholder
java -jar xdbinstalldir_placeholder/bin/edb-repcli.jar -createpub xdbtest -repsvrfile xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables public.pgbench_accounts public.pgbench_branches public.pgbench_tellers -repgrouptype M -standbyconflictresolution 1:E 2:E 3:E

# Add other masters
for i in ${OTHER_MASTER_IPS}
do
    java -jar xdbinstalldir_placeholder/bin/edb-repcli.jar -repsvrfile xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf -addpubdb -dbtype enterprisedb -dbhost ${i} -dbuser enterprisedb -dbpassword `cat xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -dbport xdbdbport_placeholder -initialsnapshot -replicatepubschema true
done

# Create Schedule
java -jar xdbinstalldir_placeholder/bin/edb-repcli.jar -repsvrfile xdbinstalldir_placeholder/etc/xdb_repsvrfile.conf -confschedulemmr basic_schedule -pubname xdbtest -realtime 5