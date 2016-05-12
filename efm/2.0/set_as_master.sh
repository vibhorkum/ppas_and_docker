#!/bin/bash

# Make sure Postgres is running
service ppas-pgmajor_placeholder stop
service ppas-pgmajor_placeholder start

psql edb enterprisedb -c "create user repuser replication"

sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/efm-2.0/efm.properties
service efm-2.0 start
