FROM centos:7
MAINTAINER vibhor.aim@gmail.com

ARG YUMUSERNAME
ARG YUMPASSWORD

ENV REPONAME=edb-as12
ENV PGMAJOR=12
ENV PGPORT=5432
ENV PGDATABASE=edb
ENV PGUSER=enterprisedb
ENV PATH=/usr/edb/as${PGMAJOR}/bin:${PATH}
ENV PGDATA=/var/lib/edb/as${PGMAJOR}/data
ENV PGLOG=${PGDATA}/log/enterprisedb.log
ENV NODE_TYPE=master
ENV MASTER_HOST=""
ENV MASTER_PORT=""

RUN rpm -ivh http://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install edb-as${PGMAJOR}-server.x86_64 sudo net-tools


RUN echo "export PGPORT=${PGPORT}"         >> /etc/profile.d/pg_env.sh
RUN echo "export PGDATABASE=${PGDATABASE}" >> /etc/profile.d/pg_env.sh
RUN echo "export PGUSER=${PGUSER}"         >> /etc/profile.d/pg_env.sh
RUN echo "export PATH=${PATH}"             >> /etc/profile.d/pg_env.sh

COPY ./start_pg.sh /usr/edb/as12/bin/start_pg.sh
RUN chmod +x /usr/edb/as12/bin/start_pg.sh

EXPOSE ${PGPORT}

CMD /usr/edb/as12/bin/start_pg.sh
