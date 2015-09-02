#!/bin/bash

psql -c "CREATE USER repuser REPLICATION"

bart init

for ((i=0;i<1000;i++));
do
  psql -c "CREATE TABLE table${i} (id serial primary key, first_name text not null default md5(random()::text), last_name text not null default md5(random()::text))" testdb
	psql -c "INSERT INTO table${i} VALUES (generate_series(1,1000),default,default)" testdb
	done

bart backup -s ppas94