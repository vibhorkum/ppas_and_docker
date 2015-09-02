#!/bin/bash

service ppas-9.4 start

psql edb enterprisedb -c "create user repuser replication"

sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/efm-2.0/efm.properties
service efm-2.0 start
