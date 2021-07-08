#!/bin/bash

psql -c "CREATE USER repuser REPLICATION"

mkdir /tmp/bart_backups

bart init

for ((i=0;i<1000;i++));
do
  psql -c "CREATE TABLE table${i} (id serial primary key, first_name text not null default md5(random()::text), last_name text not null default md5(random()::text))" edb
	psql -c "INSERT INTO table${i} VALUES (generate_series(1,1000),default,default)" edb
	done

bart backup -s epas9x