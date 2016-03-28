FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG EDBUSERNAME
ARG EDBPASSWORD
ARG INSTALLER_FILENAME

# create placeholder dirs
RUN mkdir -p /opt/apache-php
RUN mkdir -p /opt/php_edbpem

# place all necessary files for PEM Server installation
COPY ${INSTALLER_FILENAME} /tmp/${INSTALLER_FILENAME}
RUN chmod 755 /tmp/${INSTALLER_FILENAME}
COPY pem_install_optionfile /tmp/pem_install_optionfile
RUN sed -i "s/existing-user=.*/existing-user=${EDBUSERNAME}/" /tmp/pem_install_optionfile
RUN sed -i "s/existing-password=.*/existing-password=${EDBPASSWORD}/" /tmp/pem_install_optionfile

# Extract PHP dependencies
RUN /tmp/${INSTALLER_FILENAME} --extract-php_edbpem /opt/php_edbpem --extract-apache-php /opt/apache-php

# Install dependencies and PEM Server
RUN /opt/apache-php/`ls /opt/apache-php` --mode unattended --prefix /usr/edb-apache-php
RUN /opt/php_edbpem/`ls /opt/php_edbpem` --mode unattended
RUN echo "service ppas-9.5 start" >> /tmp/install_pem_server.sh
RUN echo "psql -c \"ALTER USER enterprisedb WITH PASSWORD '`cat /tmp/pem_install_optionfile | grep pgpassword | cut -f2 -d'='`'\"" >> /tmp/install_pem_server.sh
RUN echo "/tmp/${INSTALLER_FILENAME} --mode unattended --optionfile /tmp/pem_install_optionfile" >> /tmp/install_pem_server.sh
RUN echo "service ppas-9.5 stop" >> /tmp/install_pem_server.sh
RUN chmod 755 /tmp/install_pem_server.sh
RUN /tmp/install_pem_server.sh

EXPOSE 8443

CMD service EnterpriseDBApachePhp start && service ppas-9.5 start && tail -F /var/log/messages
