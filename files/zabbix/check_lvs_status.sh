#!/bin/bash

CONF="/etc/keepalived/keepalived.conf"
VIP_MOUNTED=0
VIP_NOTMOUNTED=0
LVS_STATUS="BACKUP"

# On recupere la liste des vip pour chaque instance vrrp
vip=$(sed -n "/virtual_ipaddress {/,/}/p" /etc/keepalived/keepalived.conf | grep dev | awk '{ print $1 }' | grep -v "^\!\!")

# On verifie la presence des vip
for i in $vip; do
	if [[ $(ip a l | grep "inet $i/" | wc -m) -gt 1 ]]; then
		#echo "$i is mounted"
		((VIP_MOUNTED++))
	else
		#echo "$i is not mounted"
		((VIP_NOTMOUNTED++))
	fi
done

#echo $VIP_MOUNTED
#echo $VIP_NOTMOUNTED

# Check lvs status
if [[ $VIP_MOUNTED -gt 0 ]] && [[ $VIP_NOTMOUNTED -eq 0 ]]; then
	LVS_STATUS="MASTER"
elif [[ $VIP_MOUNTED -eq 0 ]] && [[ $VIP_NOTMOUNTED -gt 0 ]]; then
	LVS_STATUS="BACKUP"
else
	LVS_STATUS="UNKNOWN"
fi

echo $LVS_STATUS
