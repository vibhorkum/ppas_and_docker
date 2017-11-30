FROM centos:6.6

MAINTAINER vibhor.aim@gmail.com
ARG YUMUSERNAME
ARG YUMPASSWORD

ENV REPONAME=edbas96
ENV FOO=96
ENV PGMAJOR=9.6
ENV PGPORT=5432
ENV PGDATABASE=edb
ENV PGUSER=enterprisedb
ENV PATH=/usr/edb-as${PGMAJOR}/bin:${PATH}
ENV PGDATA=/var/lib/edb/as${PGMAJOR}/data
ENV PGLOG=/var/lib/edb/as${PGMAJOR}/pgstartup.log

RUN rpm -ivh http://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

RUN yum -y update
RUN yum -y --enablerepo=enterprisedb-dependencies --enablerepo=${REPONAME} install edb-as${FOO}-server.x86_64 sudo

RUN echo 'root:root'|chpasswd

# setting postgres user for login
RUN adduser --home-dir /home/postgres --create-home postgres
RUN echo 'postgres   ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'postgres:postgres'|chpasswd

RUN service edb-as-${PGMAJOR} initdb

RUN sed -i "s/^PGPORT.*/PGPORT=${PGPORT}/" /etc/sysconfig/edb/as${PGMAJOR}/edb-as-${PGMAJOR}.sysconfig

RUN echo "export PGPORT=${PGPORT}"         >> /etc/profile.d/pg_env.sh
RUN echo "export PGDATABASE=${PGDATABASE}" >> /etc/profile.d/pg_env.sh
RUN echo "export PGUSER=${PGUSER}"         >> /etc/profile.d/pg_env.sh
RUN echo "export PATH=${PATH}"             >> /etc/profile.d/pg_env.sh

RUN echo "local  all         all                 trust" >  ${PGDATA}/pg_hba.conf
RUN echo "local  replication all                 trust" >> ${PGDATA}/pg_hba.conf
RUN echo "host   replication repuser  0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf
RUN echo "host   all         all      0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf

RUN sed -i "s/^port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf


RUN sed -i "s/^logging_collector = off/logging_collector = on/" ${PGDATA}/postgresql.conf                                                                                  
RUN sed -i "s/^#wal_level.*/wal_level=hot_standby/" ${PGDATA}/postgresql.conf
RUN sed -i "s/^#wal_keep_segments = 0/wal_keep_segments = 500/" ${PGDATA}/postgresql.conf
RUN sed -i "s/^#max_wal_senders = 0/max_wal_senders = 5/" ${PGDATA}/postgresql.conf

EXPOSE ${PGPORT}

CMD service edb-as-${PGMAJOR} start && tail -F ${PGLOG}
