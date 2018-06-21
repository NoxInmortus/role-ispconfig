#!/bin/bash
# Check xen version

xm info | grep major | awk '{ print $3 }'
