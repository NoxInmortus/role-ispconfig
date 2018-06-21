#!/bin/bash

mysqladmin -h $3 -u$1 -p$2 ping 2>&1 | grep -v failed
