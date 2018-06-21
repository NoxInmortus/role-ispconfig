#!/bin/bash
# Script to detect auto interface not mounted

for i in $(grep "^auto\|^allow-hotplug" /etc/network/interfaces | awk '{ print $2 }' | grep -v "^lo"); do
        if [[ $(ip address list $i 2> /dev/null | grep "global" | grep $i | wc -m) -le 1 ]]; then
                MOUNTIF=${MOUNTIF}" $i"
        fi
done

if [ $(echo $MOUNTIF | wc -m) -gt 1 ]; then
        echo "Failed on $MOUNTIF"
        exit 1
else   
        echo "Interface ok"
        exit 0
fi
