#!/bin/bash

UPTIME=$(echo "show global status where Variable_name='$1';" | mysql -h $4 -N -u$2 -p$3 | awk '{print $2}')

if [[ $UPTIME != *[!0-9]* ]];then
        if [ -z $UPTIME ];then
                echo -2
        else   
                echo $UPTIME
        fi
else   
        echo -1
fi
