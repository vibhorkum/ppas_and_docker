FROM ppas94:latest
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD

RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# run update and install require packages.
RUN yum install -y which efm20 java-1.6.0-openjdk

RUN mkdir -p /opt/backup
RUN mkdir -p /var/lib/ppas/9.4/wal_archive
RUN chown -R enterprisedb:enterprisedb /var/lib/ppas
RUN chown enterprisedb:enterprisedb /opt/backup

# copy EFM files into place
COPY set_as_master.sh /usr/efm-2.0/bin/set_as_master.sh
COPY set_as_witness.sh /usr/efm-2.0/bin/set_as_witness.sh
COPY set_as_standby.sh /usr/efm-2.0/bin/set_as_standby.sh
COPY efm.properties /etc/efm-2.0/efm.properties
RUN cp /etc/efm-2.0/efm.nodes.in /etc/efm-2.0/efm.nodes

# expose ports.
EXPOSE 5431 5430

CMD service ppas-9.4 restart && tail -F /var/log/messages
