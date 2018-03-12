FROM ppas95:latest
MAINTAINER vibhor.aim@gmail.com

ARG YUMUSERNAME
ARG YUMPASSWORD

ENV XDB_VERSION=6.2
ENV INSTALLDIR=/usr/ppas-xdb-${XDB_VERSION}
ENV JAVA_VERSION=1.7
ENV REPONAME="enterprisedb-xdb60"

# install required packages.
RUN rpm -ivh http://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo
RUN yum -y install yum-plugin-ovl
RUN yum -y --enablerepo=enterprisedb-tools --enablerepo=enterprisedb-dependencies --enablerepo=${REPONAME} install ppas-xdb which java-${JAVA_VERSION}.0-openjdk-devel

# tweak conf files so logical replication can happen
RUN sed -i "s/^wal_level.*/wal_level = logical/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN sed -i "s/^log_line_prefix.*/log_line_prefix = '%m [user=%u,db=%d %r APP=%a PID=%p XID=%x]'/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
RUN echo "host replication enterprisedb 0.0.0.0/0 trust" >> /var/lib/ppas/${PGMAJOR}/data/pg_hba.conf

# set up xDB
COPY edb-repl.conf /etc/edb-repl.conf
RUN chown enterprisedb:enterprisedb /etc/edb-repl.conf
RUN chmod 600 /etc/edb-repl.conf
COPY xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_repsvrfile.conf
COPY xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_subsvrfile.conf
RUN sed -i "s/9051/9052/" ${INSTALLDIR}/etc/xdb_subsvrfile.conf

# fill in placeholders
COPY build_xdb_mmr_publication.sh ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
COPY build_xdb_smr_publication.sh ${INSTALLDIR}/bin/build_xdb_smr_publication.sh
RUN sed -i "s/xdbinstalldir_placeholder/\/usr\/ppas-xdb-${XDB_VERSION}/g" ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
RUN sed -i "s/xdbinstalldir_placeholder/\/usr\/ppas-xdb-${XDB_VERSION}/g" ${INSTALLDIR}/bin/build_xdb_smr_publication.sh
RUN sed -i "s/xdbdbport_placeholder/${PGPORT}/g" ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
RUN sed -i "s/xdbdbport_placeholder/${PGPORT}/g" ${INSTALLDIR}/bin/build_xdb_smr_publication.sh

EXPOSE 9051 9052

CMD service ppas-${PGMAJOR} start && tail -F /var/log/messages
