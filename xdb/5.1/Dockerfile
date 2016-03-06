FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD

RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# run update and install require packages.
RUN yum -y install --nogpgcheck -y ppas-xdb.x86_64 ppas-xdb-console.x86_64 ppas-xdb-libs.x86_64 ppas-xdb-publisher.x86_64 which

# set up xDB
COPY edb-repl.conf /etc/edb-repl.conf
COPY xdb_repsvrfile.conf /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf
COPY build_xdb_smr_publication.sh /usr/ppas-xdb-5.1/bin/build_xdb_smr_publication.sh
COPY build_xdb_mmr_publication.sh /usr/ppas-xdb-5.1/bin/build_xdb_mmr_publication.sh

EXPOSE 9051

CMD service ppas-9.5 start && tail -F /var/log/messages
