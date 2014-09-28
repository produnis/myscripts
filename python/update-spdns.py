#!/usr/bin/env python
#
import os
import re
import subprocess
import urllib2

# this script checks your current IP and updates your spdns.org account accordingly.
# I run it as a cron job.
# Change username, passwd and url in lines 27-29 to fit your setup.
# Have fun.
# -----------------------------------------------------------------



# get my current IP
#-------------------------
befehl = "wget -qO- http://ipecho.net/plain ; echo"
process = subprocess.Popen(befehl.split(), stdout=subprocess.PIPE)
myip =  process.communicate()[0]
print myip
#-------------------------


# update produnis.spdns.org
#--------------------------
theurl = "https://www.spdns.de/nic/update?hostname=%s&myip=%s" % ("YOURAACOUNT.spdns.XYZ", myip)
username = "REPLACE WITH YOUR USERNAME"
password = "REPLACE WITH YOUR PASSWD"

# this creates a password manager
passman = urllib2.HTTPPasswordMgrWithDefaultRealm() 

passman.add_password(None, theurl, username, password) 
# because we have put None at the start it will always
# use this username/password combination for  urls
# for which `theurl` is a super-url


# create the AuthHandler
authhandler = urllib2.HTTPBasicAuthHandler(passman)
opener = urllib2.build_opener(authhandler)


urllib2.install_opener(opener)
# All calls to urllib2.urlopen will now use our handler
# Make sure not to include the protocol in with the URL, or
# HTTPPasswordMgrWithDefaultRealm will be very confused.
# You must (of course) use it when fetching the page though.

pagehandle = urllib2.urlopen(theurl)
# authentication is now handled automatically for us
#--------------------------
