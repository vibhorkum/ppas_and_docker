#!/bin/bash

# Script to be run on to-be standby
MASTER_HOST=${1}
ARCHIVE_DIR="/var/lib/ppas/9.4/wal_archive"
DATADIR='/var/lib/ppas/9.4/data'

# Make sure repuser exists already
if [[ `psql -h ${MASTER_HOST} -Atc "SELECT count(*) FROM pg_shadow WHERE usename = 'repuser'" edb enterprisedb` -eq 0 ]]
then
  psql -h ${MASTER_HOST} edb enterprisedb -c "CREATE USER repuser REPLICATION"
fi
  
# Stop existing local postgres service
service ppas-9.4 stop

# Create archive_dir for archive_command
rm -rf ${ARCHIVE_DIR}
mkdir -p ${ARCHIVE_DIR}
chmod 700 ${ARCHIVE_DIR}
chown -R enterprisedb:enterprisedb ${ARCHIVE_DIR}

# Create $PGDATA
rm -rf ${DATADIR}
mkdir -p ${DATADIR}

# Perform base backup
pg_basebackup -U repuser -h ${MASTER_HOST} -D ${DATADIR} -xPR

# Fix up confs so that this machine is a valid EFM standby
echo "trigger_file='/tmp/efm_standby_trigger'" >> ${DATADIR}/recovery.conf
if [[ `grep -c "^hot_standby" ${DATADIR}/postgresql.conf` -gt 0 ]]
then
    sed -i "s/^hot_standby.*/hot_standby = on/" ${DATADIR}/postgresql.conf
else
    echo "hot_standby = on" >> ${DATADIR}/postgresql.conf
fi

# more cleanup
chown -R enterprisedb:enterprisedb ${DATADIR}
chmod 700 ${DATADIR}

# Start postgres
service ppas-9.4 start

# Configure and start EFM
sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/efm-2.0/efm.properties
echo "${MASTER_HOST}:5430" >> /etc/efm-2.0/efm.nodes
service efm-2.0 start

