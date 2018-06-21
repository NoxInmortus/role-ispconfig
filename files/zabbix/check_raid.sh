#!/bin/bash
# Script de check raid pour zabbix

isvirtual=$(facter 2> /dev/null  | grep is_virtual | awk '{ print $3 }')
manufacturer=$(facter 2> /dev/null  | grep "^manufacturer" | awk '{ print $3 }')

if [[ $isvirtual =~ "false" && ! $manufacturer =~ "Bochs" ]];then
        perl /usr/local/scripts/awh-puppet/zabbix/check_raid.pl
else   
        echo "OK: Not supported"
fi
