FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG EDBUSERNAME
ARG EDBPASSWORD
ARG INSTALLER_FILENAME

# create placeholder dirs
RUN mkdir -p /opt/languagepack
RUN mkdir -p /opt/apache-httpd

# place all necessary files for PEM Server installation
COPY ${INSTALLER_FILENAME} /tmp/${INSTALLER_FILENAME}
RUN chmod 755 /tmp/${INSTALLER_FILENAME}
COPY pem_install_optionfile /tmp/pem_install_optionfile
RUN sed -i "s/existing-user=.*/existing-user=${EDBUSERNAME}/" /tmp/pem_install_optionfile
RUN sed -i "s/existing-password=.*/existing-password=${EDBPASSWORD}/" /tmp/pem_install_optionfile

# Extract Python dependencies
RUN /tmp/${INSTALLER_FILENAME}  --extract-languagepack /opt/languagepack --extract-apache-httpd /opt/apache-httpd

# Install dependencies and PEM Server
RUN /opt/languagepack/`ls /opt/languagepack` --mode unattended --prefix /usr/edb-languagepack
RUN /opt/apache-httpd/`ls /opt/apache-httpd` --mode unattended --prefix /usr/edb-apache-httpd
RUN echo "service ppas-9.5 start" >> /tmp/install_pem_server.sh
RUN echo "psql -c \"ALTER USER enterprisedb WITH PASSWORD '`cat /tmp/pem_install_optionfile | grep pgpassword | cut -f2 -d'='`'\"" >> /tmp/install_pem_server.sh
RUN echo "/tmp/${INSTALLER_FILENAME} --mode unattended --optionfile /tmp/pem_install_optionfile" >> /tmp/install_pem_server.sh
RUN echo "service ppas-9.5 stop" >> /tmp/install_pem_server.sh
RUN chmod 755 /tmp/install_pem_server.sh
RUN /tmp/install_pem_server.sh

EXPOSE 8443

CMD service EnterpriseDBApacheHTTPD start && service ppas-9.5 start && tail -F /var/log/messages
