#!/bin/bash

PEM_SERVER_INSTALL=`ls /root | grep pem_server-.*-linux-x64.run`

# create placeholder dirs
mkdir -p /opt/apache-php
mkdir -p /opt/php_edbpem

# extract Apache/PHP package
/root/${PEM_SERVER_INSTALL} --extract-php_edbpem /opt/php_edbpem --extract-apache-php /opt/apache-php

# install Apache/PHP
APACHEPHP_INSTALL=`ls /opt/apache-php | grep apachephp-.*-linux-x64.run`
PHP_EDBPEM_INSTALL=`ls /opt/php_edbpem | grep php_edbpem-.*-linux-x64.run`
/opt/apache-php/${APACHEPHP_INSTALL} --mode unattended --optionfile /root/apache_php_install_optionfile
/opt/php_edbpem/${PHP_EDBPEM_INSTALL} --mode unattended

# install PEM Server
/root/${PEM_SERVER_INSTALL} --mode unattended --optionfile /root/pem_install_optionfile
