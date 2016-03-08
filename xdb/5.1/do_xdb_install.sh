#!/bin/bash

INSTALLER_FILENAME=${1}
EDBUSERNAME=${2}
EDBPASSWORD=${3}
INSTALLDIR=${4}
PGMAJOR=${5}

service ppas-${PGMAJOR} start
sleep 10
/tmp/${INSTALLER_FILENAME} --existing-user ${EDBUSERNAME} --existing-password ${EDBPASSWORD} --mode unattended --pguser enterprisedb --controldb xdb_ctl --pghost 127.0.0.1 --prefix ${INSTALLDIR}
sleep 10
service ppas-${PGMAJOR} stop
