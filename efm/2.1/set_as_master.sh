#!/bin/bash

PGMAJOR=null

# Make sure Postgres is running
service ppas-${PGMAJOR} stop
service ppas-${PGMAJOR} start

psql edb enterprisedb -c "create user repuser replication"

sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/efm-2.1/efm.properties
service efm-2.1 start
