#!/bin/bash

PEM_SERVER_INSTALL=`ls /root | grep pem_server-.*-linux-x64.run`

# setting temporary password
psql edb enterprisedb -c "ALTER USER enterprisedb WITH PASSWORD 'abc123'" &> /dev/null

# create placeholder dirs
printf "\e[0;33m==== Extracting dependencies for PEM Server ====\n\e[0m"
mkdir -p /opt/apache-php
mkdir -p /opt/php_edbpem

# extract Apache/PHP package
/root/${PEM_SERVER_INSTALL} --extract-php_edbpem /opt/php_edbpem --extract-apache-php /opt/apache-php

# install Apache/PHP
printf "\e[0;33m==== Installing Apache/PHP for Web-based PEM Console ====\n\e[0m"
APACHEPHP_INSTALL=`ls /opt/apache-php | grep apachephp-.*-linux-x64.run`
PHP_EDBPEM_INSTALL=`ls /opt/php_edbpem | grep php_edbpem-.*-linux-x64.run`
/opt/apache-php/${APACHEPHP_INSTALL} --mode unattended --prefix /usr/edb-apache-php
/opt/php_edbpem/${PHP_EDBPEM_INSTALL} --mode unattended

# install PEM Server
printf "\e[0;33m==== Installing PEM Server ====\n\e[0m"
/root/${PEM_SERVER_INSTALL} --mode unattended --optionfile /root/pem_install_optionfile
