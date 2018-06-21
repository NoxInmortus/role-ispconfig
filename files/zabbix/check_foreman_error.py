#!/usr/bin/python

import pycurl
import urllib
import json
#import pprint
from io import BytesIO


data = BytesIO()

postData =  {'search': 'last_report > "35 minutes ago" and (status.failed > 0 or status.failed_restarts > 0) and status.enabled = true'}
c = pycurl.Curl()
c.setopt(c.WRITEFUNCTION, data.write)
c.setopt(pycurl.URL, 'https://foreman.nexen.net/api/hosts' + '?' + urllib.urlencode(postData))
c.setopt(pycurl.SSL_VERIFYPEER, 0)
c.setopt(pycurl.HTTPHEADER, ['Accept: version=2,application/json'])
c.setopt(pycurl.HTTPHEADER, ['Content-Type : application/x-www-form-urlencoded'])
c.setopt(pycurl.HTTPGET, 1)

c.perform()

hostlist = json.loads(data.getvalue())

if hostlist:
        print("CRITICAL -"),
        for h in hostlist:
                print(h["host"]["name"]),
else:  
        print("OK - No host error")
