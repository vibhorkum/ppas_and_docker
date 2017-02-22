FROM gisjedi/gosu-centos
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD 

ENV PGMAJOR=9.6
ENV SHORTVER=96
ENV PGPORT=5432
ENV PGDATABASE=edb
ENV PGUSER=enterprisedb
ENV PATH=/usr/edb/as${PGMAJOR}/bin:${PATH}
ENV PGDATA=/var/lib/edb/as${PGMAJOR}/data
ENV PGLOG=/var/lib/edb/as${PGMAJOR}/pgstartup.log

RUN rpm -ivh http://yum.enterprisedb.com/edbrepos/edb-repo-9.6-4.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

RUN yum -y update
RUN yum -y --enablerepo=edbas${SHORTVER} --enablerepo=enterprisedb-dependencies install edb-as${SHORTVER}-server.x86_64 sudo

RUN echo 'root:root'|chpasswd

# setting postgres user for login
RUN adduser --home-dir /home/postgres --create-home postgres
RUN echo 'postgres   ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'postgres:postgres'|chpasswd

RUN gosu enterprisedb initdb -D ${PGDATA}

RUN sed -i "s/^PGPORT.*/PGPORT=${PGPORT}/" /etc/sysconfig/edb/as${PGMAJOR}/edb-as-${PGMAJOR}.sysconfig

RUN echo "export PGPORT=${PGPORT}"         >> /etc/profile.d/pg_env.sh
RUN echo "export PGDATABASE=${PGDATABASE}" >> /etc/profile.d/pg_env.sh
RUN echo "export PGUSER=${PGUSER}"         >> /etc/profile.d/pg_env.sh
RUN echo "export PATH=${PATH}"             >> /etc/profile.d/pg_env.sh

RUN echo "local  all         all                 trust" >  ${PGDATA}/pg_hba.conf
RUN echo "local  replication all                 trust" >> ${PGDATA}/pg_hba.conf
RUN echo "host   replication repuser  0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf
RUN echo "host   all         all      0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf

RUN sed -i "s/^#port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf
RUN sed -i "s/^port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf
RUN sed -i "s/^logging_collector = off/logging_collector = on/" ${PGDATA}/postgresql.conf                                                                                  
RUN sed -i "s/^#wal_level.*/wal_level=hot_standby/" ${PGDATA}/postgresql.conf
RUN sed -i "s/^#wal_keep_segments = 0/wal_keep_segments = 500/" ${PGDATA}/postgresql.conf
RUN sed -i "s/^#max_wal_senders = 0/max_wal_senders = 5/" ${PGDATA}/postgresql.conf

EXPOSE ${PGPORT}

CMD pg_ctl -D ${PGDATA} start && tail -F ${PGLOG}

# To create a container with this image:
#   docker run --privileged -itd -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup %%image_name%% /usr/sbin/init # and any additional flags you want
#   docker exec -it %%container_hash%% systemctl enable edb-as-9.6.service
#   docker exec -it %%container_hash%% systemctl start edb-as-9.6.service
#   docker exec -it %%container_hash%% psql -l
