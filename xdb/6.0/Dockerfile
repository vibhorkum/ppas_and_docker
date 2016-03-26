FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG INSTALLER_FILENAME
ARG EDBUSERNAME
ARG EDBPASSWORD

ENV XDB_VERSION=6.0
ENV INSTALLDIR=/usr/ppas-xdb-${XDB_VERSION}
ENV JAVA_VERSION=1.7

# install required packages.
RUN yum -y install java-${JAVA_VERSION}.0-openjdk-devel

# tweak conf files so logical replication can happen
RUN sed -i "s/^wal_level.*/wal_level = logical/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN sed -i "s/^log_line_prefix.*/log_line_prefix = '%m [user=%u,db=%d %r APP=%a PID=%p XID=%x]'/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN echo "host replication enterprisedb 0.0.0.0/0 trust" >> /var/lib/ppas/${PGMAJOR}/data/pg_hba.conf

RUN touch /etc/postgres-reg.ini
COPY ${INSTALLER_FILENAME} /tmp/${INSTALLER_FILENAME}
RUN chmod 755 /tmp/${INSTALLER_FILENAME}

# install and set up xDB
RUN /tmp/${INSTALLER_FILENAME} --existing-user ${EDBUSERNAME} --existing-password ${EDBPASSWORD} --mode unattended --admin_user enterprisedb --admin_password abc123 --prefix ${INSTALLDIR} --disable-components subserver
COPY xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_repsvrfile.conf
COPY build_xdb_mmr_publication.sh ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
RUN sed -i "s/xdbinstalldir_placeholder/\/usr\/ppas-xdb-${XDB_VERSION}/g" ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
RUN sed -i "s/xdbdbport_placeholder/${PGPORT}/g" ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh

EXPOSE 9051 9052

CMD service ppas-${PGMAJOR} start && tail -F /var/log/messages
