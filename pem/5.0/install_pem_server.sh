#!/bin/bash

# install sslutils
cd /root/sslutils-1.1
make USE_PGXS=1 
make USE_PGXS=1 install

# create placeholder dirs
mkdir -p /opt/apache-php
mkdir -p /opt/php_edbpem

# extract Apache/PHP package
/root/pem_server-5.0.0-2-linux-x64.run --extract-php_edbpem /opt/php_edbpem --extract-apache-php /opt/apache-php

# install Apache/PHP
/opt/apache-php/apachephp-2.4.10-5.5.19-1-linux-x64.run --mode unattended --optionfile /root/apache_php_install_optionfile
/opt/php_edbpem/php_edbpem-5.5.19-5.0.0-2-linux-x64.run --mode unattended

# install PEM Server
/root/pem_server-5.0.0-2-linux-x64.run --mode unattended --optionfile /root/pem_install_optionfile