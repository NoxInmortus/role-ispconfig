#!/bin/bash
# Check ipvsadm md5

IPVSADM=$(which ipvsadm)

$IPVSADM -Ln | awk '{ print $1,$2 }' | md5sum | awk '{ print $1 }'
