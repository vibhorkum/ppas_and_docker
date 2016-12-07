#!/bin/bash

sed -i "s/is.witness=.*/is.witness=true/" /etc/efm-2.1/efm.properties
sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/efm-2.1/efm.properties

service efm-2.1 start
