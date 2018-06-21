#! /usr/local/bin/python

import sys
import os
import re
import getopt

try:
        opts, args = getopt.getopt(sys.argv[1:], "s:u:p:", ["server=","username=","password="])
except getopt.GetoptError as err:
        # Affiche l'aide et quitte le programme
        print("CRITICAL - ", err) # Va afficher l'erreur en anglais
        sys.exit(2)

for opt, arg in opts:
        if opt in ("-s", "--server"):
                SMTPserver = arg
        elif opt in ("-u", "--username"):
                sender = arg
                USERNAME = arg
        elif opt in ("-p", "--password"):
                PASSWORD = arg

destination = ['null@null.nexen.net']

# typical values for text_subtype are plain, html, xml
text_subtype = 'plain'


content="""\
Test message
"""

subject="Sent from supervision"


#from smtplib import SMTP_SSL as SMTP       # this invokes the secure SMTP protocol (port 465, uses SSL)
from smtplib import SMTP                  # use this for standard SMTP protocol   (port 25, no encryption)
from email.MIMEText import MIMEText       

try:
    msg = MIMEText(content, text_subtype)
    msg['Subject']=       subject
    msg['From']   = sender # some SMTP servers will do this automatically, not all

    conn = SMTP(SMTPserver)
    conn.set_debuglevel(False)
    conn.starttls()
    conn.login(USERNAME, PASSWORD)
    try:
        conn.sendmail(sender, destination, msg.as_string())
        print "OK - Mail send"
    finally:
        conn.close()

except Exception, exc:
    sys.exit( "CRITICAL - mail failed; %s" % str(exc) ) # give a error message
