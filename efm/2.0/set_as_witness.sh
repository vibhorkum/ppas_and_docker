#!/bin/bash

sed -i "s/is.witness=.*/is.witness=true/" /etc/efm-2.0/efm.properties
sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/efm-2.0/efm.properties

service efm-2.0 start
