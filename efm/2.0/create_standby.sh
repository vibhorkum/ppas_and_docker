#!/bin/bash

# Script to be run on to-be standby
MASTER_HOST=''

service ppas-9.4 initdb
pg_basebackup -U repuser -h ${MASTER_HOST} -D /var/lib/ppas/9.4/data -xP
service ppas-9.4 start
