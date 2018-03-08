FROM epas10:latest
MAINTAINER vibhor.aim@gmail.com

ARG EDBUSERNAME
ARG EDBPASSWORD
ARG INSTALLER_FILENAME

# create placeholder dirs
RUN mkdir -p /opt/languagepack
RUN mkdir -p /opt/pem-httpd
RUN yum -y --enablerepo=edbas10 update edb-as10-server-sslutils

# place all necessary files for PEM Server installation
COPY ${INSTALLER_FILENAME} /tmp/${INSTALLER_FILENAME}
RUN chmod 755 /tmp/${INSTALLER_FILENAME}
COPY pem_install_optionfile /tmp/pem_install_optionfile
RUN sed -i "s/existing-user=.*/existing-user=${EDBUSERNAME}/" /tmp/pem_install_optionfile
RUN sed -i "s/existing-password=.*/existing-password=${EDBPASSWORD}/" /tmp/pem_install_optionfile

# Extract dependencies
RUN /tmp/${INSTALLER_FILENAME}  --extract-languagepack /opt/languagepack --extract-pem-httpd /opt/pem-httpd

# Install dependencies and PEM Server
RUN /opt/languagepack/`ls /opt/languagepack` --mode unattended --prefix /usr/edb-languagepack
RUN /opt/pem-httpd/`ls /opt/pem-httpd` --mode unattended --prefix /usr/edb-pem-httpd
RUN echo "service pemagent start" >> /tmp/install_pem_server.sh
RUN echo "service edb-as-10 start" >> /tmp/install_pem_server.sh
RUN echo "psql -c \"ALTER USER enterprisedb WITH PASSWORD '`cat /tmp/pem_install_optionfile | grep pgpassword | cut -f2 -d'='`'\"" >> /tmp/install_pem_server.sh
RUN echo "/tmp/${INSTALLER_FILENAME} --mode unattended --optionfile /tmp/pem_install_optionfile" >> /tmp/install_pem_server.sh
RUN echo "service edb-as-10 stop" >> /tmp/install_pem_server.sh
RUN chmod 755 /tmp/install_pem_server.sh
RUN /tmp/install_pem_server.sh

EXPOSE 8443

CMD service PEMHTTPD start && service edb-as-10 start && tail -F /var/log/messages
