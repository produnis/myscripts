#!/usr/bin/env python3
#------------------------------------------------
## 					Welcome to mwc2pdf
## ----------------------------------------------
## Media Wiki Category To PDF (mwc2pdf)...
## - is a php script that exports a Category from MediaWiki
##   into PDF, including all pages of that category as well as 
##   all pages from subcategories.
## - mwc2pdf uses MediaWiki's  "api.php" to collect all data 
##   and it creates a sorted "pagetree" without doubles/twin entries.
## - mwc2pdf downloads every item of that pagetree as a PDF-file
##   using mediawiki's "Mpdf" extension.
## - It then combines all pdf-files into one single pdf-file
##   called "MWC2PDF-Output.pdf" 
## - It uses "PyPDF2" to set some bookmarks while creating
##   the single pdf-file.
##
##   All files are generated in the directory you call mwc2pdf.py from
##   So, make sure you have write-permission to that path!
## -----------------------------------------------
##
## REQUIERES:
## ##########
## - mediawiki >= 1.32, with:
## -- Mpdf extension
## -- you having set up Special:BotPasswords for your account
## - Python3  with:
## - -- PyPDF2
##
## if your Wiki has long pages, 
## you might want to set
##      max_execution_time = 360
## in php.ini to avoid timeout-errors
## while rendering the PDF-file.
## -------------------------
## Written by Joe Slam 2015-2019
## Licence: GPL v3
## -------------------------
##
##
## USAGE:
## ######
## 1) Change the lines 52-59
##    to fit your situation
## 2) open terminal
## 3) ./PATH/TO/mwc2pdf.py
##
####################################################################

# + + + + + + + + + + + + + + + + + + + + + + +
## Change this vars to fit your system
mywiki 			= "https://de.wikipedia.org/w/"	# URL to your wiki's index.php
kategorie 		= "Kategorie:Hauptkategorie"	# Which Category to grab?
kategorie_word 		= "Kategorie:"			# What is "Category:" in your wiki's language?
username 		= 'produnis'			# Username to login with
userpwd			= 'SuperSecret'			# Userpassword
botpwd 			= 'myapibot@foobarfoobarfoobar'	# Password of Special:BotPasswords in the style BOTNAME@password
# + + + + + + + + + + + + + + + + + + + + + + +
keep_tmp_pdfs = "no"  	# switch "no" / "yes" to keep tmp-pdf-files of every page

#____________________________________________________________________
# ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  ! ! ! !
## Dont change after here...
# ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  ! ! ! !
##----------------------------------------------
import os
from PyPDF2 import utils, PdfFileReader, PdfFileWriter
import sys
import datetime
import time			
import requests
from bs4 import BeautifulSoup as bs


right_now 	= datetime.datetime.now()
index_url 	= mywiki + "index.php"
api_url 	= mywiki + 'api.php'

#-----------------------------------------------------------------
## Login to MediaWiki API
# we use the API to get some Info about the Categories and Pages. 
session = requests.Session()

# get login token
#print("session cookies before r1: ", dict(session.cookies))
r1 = session.get(api_url, params={
    'format': 'json',
    'action': 'query',
    'meta': 'tokens',
    'type': 'login',
})
#r1.raise_for_status()
#print(r1.json())
#print("session cookies after r1: ", dict(session.cookies))
# log in
r2 = session.post(api_url, data={
    'format': 'json',
    'action': 'login',
    'lgname': username,
    'lgpassword': botpwd,
    'lgtoken': r1.json()['query']['tokens']['logintoken'],
})

#print("session cookies after r2: ", dict(session.cookies))
#print("request body: ", r2.request.body)
if r2.json()['login']['result'] != 'Success':
    raise RuntimeError(r2.json())
#-----------------------------------------------------------------



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# login as "normal" user (to get PDFs)
# we need to log in to mediawiki as "normal" user in order to
# call the Mpdf-Extension
payload = {
	'wpName': username,
	'wpPassword': userpwd,
	'wploginattempt': 'Log in',
	'wpEditToken': "+\\",
	'title': "Special:UserLogin",
	'authAction': "login",
	'force': "",
	'wpForceHttps': "1",
	'wpFromhttp': "1",
    #'wpLoginToken': '',
	}

def get_login_token(raw_resp):
	soup = bs(raw_resp.text, 'lxml')
	token = [n.get('value', '') for n in soup.find_all('input')
		if n.get('name', '') == 'wpLoginToken']
	return token[0]
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	



# Functions
#-------------------
def startsWith(haystack, needle):
	 # this function checks if the string 
	 # "$hayshack" starts with the letters "$neddle"
	 # And returns TRUE or FALSE
     length = len(needle)
     return (haystack[:length] == needle)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#---- end of functions --------------
	


		
#### M A I N   S C R I P T
#-------------------------
print("\n\nCollecting data for %s \n\n" % (kategorie))

# Get pageid of start-category
MyParams = {
	"action": "query",
	"format": "json",
	"prop": "pageprops",
	"titles": kategorie
}
mycontent = session.get(api_url, params=MyParams)
mydata=mycontent.json
for key in mydata()['query']['pages']:
	#print("loop ", key)
	current_parent = key
print("current parent: %s" % (current_parent))
#-------------------------





# Setting up all important vars() and arrays()
#---------------------------------------------
x 					= 0
y 					= 0
next_level 			= 0
current_level 		= 0
done 				= False
my_break			= False
the_pageids 		= None
the_names 			= None
loop_list 			= None
the_pageids = []
the_pageids.append(current_parent)
the_names = []
the_names.append(kategorie)
the_prefix = []
the_prefix.append("p0_")
the_parentid = []
the_parentid.append(0)
the_level = []
the_level.append(0)
is_category = []
is_category.append("C")
loop_list = []
loop_list.append(kategorie)
loop_id = []
loop_id.append(current_parent)
loop_prefix = []
loop_prefix.append("p0_")
#---------------------------------

x = x + 1


#####################################
# MAIN Category LOOP
#----------------------

while done == False:
	
	#get content of current category
	current_parent = loop_id[y]
	MyParams = {
		"action": "query",
		"format": "json",
		"list": "categorymembers",
		"cmlimit": 500,
		"cmpageid": current_parent
	}
	mycontent = session.get(api_url, params=MyParams)
	mydata=mycontent.json
	#print("current parent: ", mydata()['query']['categorymembers'])
	# get id and title for each content
	for item in mydata()['query']['categorymembers']:
		#print(item['pageid'], " - ", item['title'])
		neuer_titel = item['title']
		neue_pageid = item['pageid']
	
		# is this a Page?
		# ---------------------------------------------------
		if (startsWith(neuer_titel, kategorie_word) == False):
			if (startsWith(neuer_titel, "Datei:") == False) and (startsWith(neuer_titel, "File:") == False) and (startsWith(neuer_titel, "Media:") == False) and (startsWith(neuer_titel, "Bild:") == False):
				# is page already in list?
				if neuer_titel in the_names:
					print("Page already in list, skipping %s" % neuer_titel)
				else: 
					print("New page found: %s" % neuer_titel)
					the_pageids.append(neue_pageid)
					the_names.append(neuer_titel)
					the_parentid.append(current_parent)
					the_level.append(current_level)
					the_prefix_dummy = "%05d" % (x)
					the_prefix_dummy2 = "%s%s" % (loop_prefix[y],the_prefix_dummy)
					the_prefix.append(the_prefix_dummy2)
					is_category.append("P")
			else:
				# This is a File. We can skip that and try the next.
				x = x - 1
		
		# is this a Category?	
		elif (startsWith(neuer_titel, kategorie_word) == True):
			if neuer_titel in the_names:
				print("Category already in list, skipping %s" % neuer_titel)
			else: 
				print("New category found: %s" % (neuer_titel))
				loop_list.append(neuer_titel)
				loop_id.append(neue_pageid)
				the_prefix_dummy = "%05d" % (x)
				the_prefix_dummy2 = "%s%s%s" % (loop_prefix[y], the_prefix_dummy, "_")
				loop_prefix.append(the_prefix_dummy2)
				the_pageids.append(neue_pageid)
				the_names.append(neuer_titel)
				the_prefix.append(the_prefix_dummy2)
				the_parentid.append(current_parent)
				level_dummy = current_level +1
				the_level.append(level_dummy)
				is_category.append("C") 	
		x = x + 1
	y = y + 1 
	current_level = current_level + 1
	if y == (len(loop_list)):
		print("Ende")
		done =True
#----------------------------
# END Main Category Loop
#############################################################################


# Multisort
the_prefix, the_pageids, the_names, the_parentid, the_level, is_category = zip(*sorted(zip(the_prefix, the_pageids, the_names, the_parentid, the_level, is_category)))


# Printing out List of Pages:
print("\n\nThis is what I got:")

i = len(the_prefix)
j = 0
while j < i:
	print_string = "%s | %s | %s: %s | Lev=%s | P=%s" % (the_prefix[j], is_category[j], the_pageids[j], the_names[j], the_level[j], the_parentid[j])
	print(print_string)
	j = j +1
#---------------------------------




#######################################
# Printing into PDF file
#______________________________________
gesamtzahl = len(the_prefix)
seitenzaehler  = 0
artikelzaehler = 0
output_pdf_stream = PdfFileWriter()

for f in the_prefix:
	prozente = round(artikelzaehler*100/gesamtzahl,3)
	print("Processing %s (%s of %s) / %s %%" % (the_names[artikelzaehler], (artikelzaehler+1), gesamtzahl, prozente) )

	# Getting PDF-Version of URL
	the_prefix_dummy = "%05d" % (artikelzaehler)
	the_filename = "%s-%s-%s_%s.mwcpdf.pdf" % (the_prefix_dummy, the_prefix[artikelzaehler], is_category[artikelzaehler], the_pageids[artikelzaehler])
	the_html_name= "%s-%s-%s_%s.mwcpdf.html" % (the_prefix_dummy, the_prefix[artikelzaehler], is_category[artikelzaehler], the_pageids[artikelzaehler])

	# log in to mediawiki as "normal user"
	with requests.session() as s:
		resp = s.get(index_url + '?title=Spezial:UserLogin')
		payload['wpLoginToken'] = get_login_token(resp)
		response_post = s.post(index_url + '?title=Spezial:UserLogin&action=submitlogin&type=login', data=payload)
		
		# get pdf-version of page, using Mpdf-Extension
		response = s.get(index_url + '?title=' + the_names[artikelzaehler] + '&action=mpdf')
		with open(the_filename, 'wb') as f:
			f.write(response.content)
	
	
		
	# Reading into PdfFileReader
	current_pdf = PdfFileReader(open(the_filename, "rb"),strict=False)
	
	# Setting Bookmarks
	the_bookmarkname = the_names[artikelzaehler].encode('utf-8')
	for i in range(current_pdf.numPages):
		output_pdf_stream.addPage(current_pdf.getPage(i))
		if i==0:
			if (is_category[artikelzaehler] == "C"):
				# Add Parent Bookmark for Category
				current_parent = output_pdf_stream.addBookmark(str(the_bookmarkname),seitenzaehler)				
			else:
				# Add Child Bookmark for Page
				output_pdf_stream.addBookmark(str(the_bookmarkname),seitenzaehler,parent=current_parent)
		seitenzaehler = seitenzaehler + 1
	
	# cleaning up temp-pdf
	if (keep_tmp_pdfs == "no"):
		os.remove(the_filename)
	
	artikelzaehler = artikelzaehler + 1
#------ Ende merging PDF with Bookmarks
	
try:
	output_pdf_name = "MWC2PDF-Output-%s-%s-%s.pdf" % (right_now.year, right_now.month, right_now.day)
	output_pdf_file = open(output_pdf_name, "wb")
	output_pdf_stream.write(output_pdf_file)
finally:
	output_pdf_file.close()

print("%s successfully created." % output_pdf_name)

# End printing into PDF-File
###############################################################


# https://stackoverflow.com/a/38378803/1493264  how to login to Mediawiki with Python
# http://superuser.com/questions/1009939/how-to-merge-pdfs-and-create-bookmarks-for-each-input-file-in-output-file-linu
# https://pypi.python.org/pypi/pdfkit/0.4.1
