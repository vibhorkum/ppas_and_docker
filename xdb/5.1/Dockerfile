FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD

ENV XDB_VERSION=5.1
ENV INSTALLDIR=/usr/ppas-xdb-${XDB_VERSION}
ENV JAVA_VERSION=1.7

# install required packages.
RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# install required packages.
RUN yum -y install ppas-xdb ppas-xdb-console ppas-xdb-libs ppas-xdb-publisher which java-${JAVA_VERSION}.0-openjdk-devel

# set up xDB
COPY edb-repl.conf /etc/edb-repl.conf
RUN chown enterprisedb:enterprisedb /etc/edb-repl.conf
RUN chmod 600 /etc/edb-repl.conf
RUN sed -i "s/^port=.*/port=${PGPORT}/" /etc/edb-repl.conf
COPY xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_repsvrfile.conf
COPY xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_subsvrfile.conf
RUN sed -i "s/9051/9052/" ${INSTALLDIR}/etc/xdb_subsvrfile.conf

# fill in placeholders
COPY build_xdb_smr_publication.sh ${INSTALLDIR}/bin/build_xdb_smr_publication.sh
RUN sed -i "s/xdbinstalldir_placeholder/\/usr\/ppas-xdb-${XDB_VERSION}/g" ${INSTALLDIR}/bin/build_xdb_smr_publication.sh
RUN sed -i "s/xdbdbport_placeholder/${PGPORT}/g" ${INSTALLDIR}/bin/build_xdb_smr_publication.sh
COPY build_xdb_mmr_publication.sh ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
RUN sed -i "s/xdbinstalldir_placeholder/\/usr\/ppas-xdb-${XDB_VERSION}/g" ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh
RUN sed -i "s/xdbdbport_placeholder/${PGPORT}/g" ${INSTALLDIR}/bin/build_xdb_mmr_publication.sh

EXPOSE 9051 9052

CMD service ppas-${PGMAJOR} start && tail -F /var/log/messages
