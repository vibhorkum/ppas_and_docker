FROM epas95:latest
MAINTAINER richard.yen@enterprisedb.com

RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# run update and install require packages.
RUN yum -y install which ppas95-server-sslutils openssl-devel

# place all necessary files for PEM Server installation
COPY apache_php_install_optionfile /root/apache_php_install_optionfile
COPY pem_install_optionfile /root/pem_install_optionfile

# Requires VPN connection
RUN wget -q --user=<user> --password=<password> --directory-prefix=/root/ https://builds.enterprisedb.com/builds/Releases/PEM/v5.0.0/GA/server/pem_server-5.0.0-2-linux-x64.run
RUN chmod 755 /root/pem_server-5.0.0-2-linux-x64.run

# allow user to decide which/where to install PEM server/agent
COPY install_pem_server.sh /root/install_pem_server.sh
COPY install_pem_agent.sh /root/install_pem_agent.sh

EXPOSE 8443

CMD service ppas-9.5 start && tail -F /var/log/messages
