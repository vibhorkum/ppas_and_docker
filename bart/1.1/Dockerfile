FROM ppas95:latest
MAINTAINER vibhor.aim@gmail.com

ARG YUMUSERNAME
ARG YUMPASSWORD

ENV BART_VERSION=1.1
ENV BART_PATH="/usr/edb-bart-${BART_VERSION}"

RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# run update and install require packages.
RUN yum -y install edb-bart tar

RUN mkdir /tmp/wal_archive
RUN chown enterprisedb:enterprisedb /tmp/wal_archive
RUN sed -i "s/^#archive_mode.*/archive_mode = on/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN sed -i "s/^#archive_command.*/archive_command = 'cp %p \/tmp\/wal_archive\/%f'/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf

# put basic test script in enterprisedb's Linux homedir
COPY bart_test.sh /var/lib/ppas/bart_test.sh

# set custom BART script
COPY bart.cfg ${BART_PATH}/etc/bart.cfg
RUN sed -i "s/pgport_placeholder/${PGPORT}/g"   ${BART_PATH}/etc/bart.cfg
RUN sed -i "s/pgmajor_placeholder/${PGMAJOR}/g" ${BART_PATH}/etc/bart.cfg

# make BART binary available in $PATH
RUN echo "export PATH=${BART_PATH}/bin:\${PATH}" >> /etc/profile.d/pg_env.sh
