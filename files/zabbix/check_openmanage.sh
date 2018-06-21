#!/bin/bash
# script de check openmanage pour zabbix

# check if srvadmin is installed
if [[ $(dpkg -l | grep srvadmin-omcommon | grep ^ii) ]]; then
        perl /usr/local/scripts/awh-puppet/zabbix/check_openmanage -s -i
else   
        echo "OK - srvadmin not installed"
fi
