FROM centos:6.6
MAINTAINER richyen3@gmail.com

# COPY all repository and Keys.
RUN mkdir -p /run/lock
RUN mkdir -p /var/lock/subsys
COPY rpmforge.repo /etc/yum.repos.d/
COPY ppas94.repo /etc/yum.repos.d/
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
	 tar                   \
   sudo                  \
   man                   \
   wget                  \
   ppas94                \
   net-tools             \
	 openssl-devel         \
	 gcc                   \
	 pem-agent-5.0.2-1.rhel6

RUN wget -q --user=<user> --password=<password> --directory-prefix=/root/ http://get.enterprisedb.com/src/sslutils-3.0.0.tar.gz
RUN tar xvzf /root/sslutils-3.0.0.tar.gz -C /root/

# setting postgres user for login
RUN perl -i -pe 's|. /etc/sysconfig/network||' /etc/init.d/ppas-9.4
RUN perl -i -pe 's|^UsePAM yes|UsePAM no|' /etc/ssh/sshd_config
RUN adduser --home-dir /home/postgres --create-home postgres
RUN echo 'postgres   ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'postgres:postgres'|chpasswd
# permitting root login
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# init the PPAS database
COPY ppas_94_sysconfig /etc/sysconfig/ppas/ppas-9.4
RUN service ppas-9.4 initdb
COPY pg_conf/pg_hba.conf /var/lib/ppas/9.4/data/pg_hba.conf
COPY pg_conf/postgresql.conf /var/lib/ppas/9.4/data/postgresql.conf
COPY ppas_env.sh /etc/profile.d/ppas_env.sh
RUN mkdir -p /opt/backup
RUN mkdir -p /var/lib/ppas/9.4/wal_archive

# set ownership
RUN chown -R enterprisedb:enterprisedb /var/lib/ppas
RUN chown enterprisedb:enterprisedb /opt/backup

# place all necessary files for PEM Server installation
COPY apache_php_install_optionfile /root/apache_php_install_optionfile
COPY pem_install_optionfile /root/pem_install_optionfile

# Requires VPN connection
RUN wget -q --user=<user> --password=<password> --directory-prefix=/root/ https://builds.enterprisedb.com/builds/Releases/PEM/v5.0.0/GA/server/pem_server-5.0.0-2-linux-x64.run
RUN chmod 755 /root/pem_server-5.0.0-2-linux-x64.run

# allow user to decide which/where to install PEM server
COPY install_pem_server.sh /root/install_pem_server.sh

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# expose ports.
EXPOSE 5432 22 80 8080 8443

# start sshd daemon so that we can do ssh
CMD service ppas-9.4 start && service pemagent start && /usr/sbin/sshd -D
