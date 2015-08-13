#!/bin/bash

MDN_IP=`hostname -i`
LIST_OF_OTHER_MASTER_IPS=''

# Start xDB
service edb-xdbpubserver start

# Load data into MDN
pgbench -h ${MDN_IP} -i -F 10 -s 10 edb

# Build xDB replication infrastructure
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -uptime
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -addpubdb -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -dbtype enterprisedb -dbhost ${MDN_IP} -dbuser enterprisedb -dbpassword `cat /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -nodepriority 1 -dbport 5432
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -createpub xdbtest -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables public.pgbench_accounts public.pgbench_branches public.pgbench_history public.pgbench_tellers -repgrouptype M

# Add other masters
for i in ${LIST_OF_OTHER_MASTER_IPS}
do
    java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -addpubdb -dbtype enterprisedb -dbhost ${i} -dbuser enterprisedb -dbpassword `cat /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -dbport 5432 -initialsnapshot -replicatepubschema true
done

# Create Schedule
java -jar /usr/ppas-xdb-5.1/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf -confschedulemmr basic_schedule -pubname xdbtest -realtime 5