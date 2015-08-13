FROM centos:6.6
MAINTAINER vibhor.aim@gmail.com

# COPY all repository and Keys.
RUN mkdir -p /run/lock
RUN mkdir -p /var/lock/subsys
COPY rpmforge.repo /etc/yum.repos.d/
COPY ppas91.repo /etc/yum.repos.d/
COPY epel.repo /etc/yum.repos.d/
COPY epel-testing.repo /etc/yum.repos.d/
COPY enterprisedb-tools.repo /etc/yum.repos.d/

COPY RPM-GPG-KEY-rpmforge-fabian /etc/pki/rpm-gpg/
COPY RPM-GPG-KEY-rpmforge-dag /etc/pki/rpm-gpg/
COPY RPM-GPG-KEY-EPEL-6 /etc/pki/rpm-gpg/
COPY ENTERPRISEDB-GPG-KEY /etc/pki/rpm-gpg/

# run update and install require packages.
RUN yum update -y
RUN yum install -y       \
   which                 \
   perl                  \
   python-paramiko       \
   vim                   \
   openssh-server        \
   openssh-clients       \
   file                  \
   sudo                  \
   man                   \
   wget                  \
   net-tools
RUN yum -y install --nogpgcheck -y ppas91 java-1.8.0-openjdk-devel.x86_64 ppas-xdb.x86_64 ppas-xdb-console.x86_64 ppas-xdb-libs.x86_64 ppas-xdb-publisher.x86_64

# setting postgres user for login
RUN perl -i -pe 's|. /etc/sysconfig/network||' /etc/init.d/ppas-9.1
RUN perl -i -pe 's|^UsePAM yes|UsePAM no|' /etc/ssh/sshd_config
RUN adduser --home-dir /home/postgres --create-home postgres
RUN echo 'postgres   ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'postgres:postgres'|chpasswd
# permitting root login
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY ppas_91_sysconfig /etc/sysconfig/ppas/ppas-9.1
RUN service ppas-9.1 initdb
COPY pg_conf/postgresql.conf /var/lib/ppas/9.1/data/postgresql.conf
COPY pg_conf/pg_hba.conf /var/lib/ppas/9.1/data/pg_hba.conf
COPY ppas_env.sh /etc/profile.d/ppas_env.sh
COPY edb-repl.conf /etc/edb-repl.conf
COPY xdb_repsvrfile.conf /usr/ppas-xdb-5.1/etc/xdb_repsvrfile.conf

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# expose ports.
EXPOSE 5432 22 80 8080 9051

# start sshd daemon so that we can do ssh
CMD service ppas-9.1 start && /usr/sbin/sshd -D
