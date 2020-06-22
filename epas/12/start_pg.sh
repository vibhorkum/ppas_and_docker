#!/bin/bash

set -x
PGHOME=/usr/edb/as12
PGBIN=${PGHOME}/bin
EFM_HOME=/usr/edb/efm-3.9

PGCTL=${PGHOME}/bin/pg_ctl

if [[ ${NODE_TYPE} = "master" ]]
then
    if [[ ! -f ${PGDATA}/PG_VERSION ]]
    then
        sudo -u ${PGUSER} \
            ${PGBIN}/initdb -D ${PGDATA} --auth-host=scram-sha-256 --data-checksums
        sudo -u ${PGUSER} \
            mkdir -p ${PGDATA}/log
        echo "local  all         all                 trust" >  ${PGDATA}/pg_hba.conf
        echo "local  replication all                 scram-sha-256" >> ${PGDATA}/pg_hba.conf
        echo "host   replication repuser  0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf
        echo "host   all         all      0.0.0.0/0  scram-sha-256" >> ${PGDATA}/pg_hba.conf
        sed -i "s/^#password_encryption = md5/password_encryption = scram-sha-256/g" ${PGDATA}/postgresql.conf
        sed -i "s/^port = .*/port = ${PGPORT}/g" ${PGDATA}/postgresql.conf
        sed -i "s/^logging_collector = off/logging_collector = on/g" ${PGDATA}/postgresql.conf

        sudo -u ${PGUSER} ${PGBIN}/pg_ctl -D ${PGDATA} start
        sudo -u ${PGUSER} ${PGBIN}/psql  -c "ALTER USER enterprisedb PASSWORD 'edb'" -p ${PGPORT} edb
        sudo -u ${PGUSER} ${PGBIN}/psql  -c "ALTER SYSTEM SET log_filename TO 'enterprisedb.log'" -p ${PGPORT} edb
        sudo -u ${PGUSER} ${PGBIN}/psql  -c "select pg_reload_conf();" -p ${PGPORT} edb
        sudo -u ${PGUSER} ${PGBIN}/psql  -c "CREATE USER repuser REPLICATION;" -p ${PGPORT} edb
    else
        sudo -u ${PGUSER} ${PGBIN}/pg_ctl -D ${PGDATA} start
    fi
else
    if [[ ${NODE_TYPE} = "standby" ]]
    then
        if [[ ! -z ${MASTER_HOST} && ! -f ${PGDATA}/PG_VERSION ]]
        then
            SLOT_NAME=$(/usr/sbin/ifconfig eth0|grep "inet"|awk '{print $2}'|sed "s/\./_/g")
            PGPASSWORD=edb ${PGBIN}/psql -U enterprisedb \
                                        -h ${MASTER_HOST} \
                                        -p ${MASTER_PORT} \
                                        -c "SELECT pg_create_physical_replication_slot('${SLOT_NAME}', true);" \
                                        edb

            sudo -u ${PGUSER} \
                PGAPPNAME=${HOSTNAME} ${PGBIN}/pg_basebackup --pgdata=${PGDATA} \
                                        --write-recovery-conf \
                                        --wal-method=stream \
                                        --slot=${SLOT_NAME} \
                                        --username=repuser \
                                        -h ${MASTER_HOST} \
                                        -p ${MASTER_PORT}

            sudo -u ${PGUSER} ${PGBIN}/pg_ctl -D ${PGDATA} start
        fi
    fi
    sudo -u ${PGUSER} ${PGBIN}/pg_ctl -D ${PGDATA} start
fi

tail -f ${PGLOG}
