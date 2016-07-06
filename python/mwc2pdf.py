#!/usr/bin/env python2
#
## Usage:
## 1) Change the three lines 49-51
##    to fit your situation
## 2) open terminal
## 3) ./PATH/TO/mwc2pdf.py
#
#
#------------------------------------------------
## 					Welcome to mwc2pdf
## ----------------------------------------------
## Media Wiki Category To PDF (MWC2PDF)
## is a php script that exports a Category from MediaWiki
## into PDF, including all Pages of that category as well as 
## all pages from subcategories.
## mwc2pdf uses MediaWiki's  "api.php" to collect 
## all data and create a "pagetree".
## mwc2pdf prints out every item of that pagetree 
## into a single pdf-file using pdfkit ("wkhtmltopdf").
## It than combines all single pdf-files into 
## one single pdf-file called "MWC2PDF-Output.pdf" using "PyPDF2".
##
## -----------------------------------------------
## Requires:
## - mediawiki >= 1.27
## - wkhtmltopdf
## - Python 2  with:
## - -- pdfkit
## - -- PyPDF2
## - -- urllib2
## -------------------------
## Written by Joe Slam 2015-2016
## Licence: GPL v3
## -------------------------
##
## Usage:
## 1) Change the three lines in 49-51 
##    to fit your situation
## 2) open terminal
## 3) $ /PATH/TO/mwc2pdf.py 
##           
## All files are generated in the directory you call mwc2pdf.py from
## So, make sure you have write-permission to that path!
####################################################################

# + + + + + + + + + + + + + + + + + + + + + + +
## Change this vars to fit your system
mywiki 			= "http://192.168.0.4/produniswiki/"# URL to your wiki's index.php
kategorie 		= "Kategorie:Hauptkategorie"				# Which Category to grab?
kategorie_word 	= "Kategorie:"						# What is "Category:" in your wiki's language?
# + + + + + + + + + + + + + + + + + + + + + + +
keep_tmp_pdfs = "no"  	# switch "no" / "yes" to keep tmp-pdf-files of every page

#____________________________________________________________________
# ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  ! ! ! !
## Dont change after here...
# ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  ! ! ! !
##----------------------------------------------
import os
import pdfkit
from PyPDF2 import utils, PdfFileReader, PdfFileWriter
import sys
import time
import urllib2  				
import xml.etree.ElementTree as ET



## API -Commands
#------------------
# List all Subcategories
cmd_subcat = "api.php?action=query&format=xml&list=categorymembers&cmlimit=500&cmtitle="
# List all Pages of Category
cmd_catinfo = "api.php?action=query&format=xml&prop=pageprops&titles="
# Get URL from pageid
cmd_geturlfromID = "api.php?action=query&format=xml&inprop=url&prop=info&pageids="





# Functions
#-------------------
def getCategoryID(myxml):
	return(myxml[0][0][0].get('pageid'))
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


def startsWith(haystack, needle):
	 # this function checks if the string 
	 # "$hayshack" starts with the letters "$neddle"
	 # And returns TRUE or FALSE
     length = len(needle)
     return (haystack[:length] == needle)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def wikiHTMLprint(the_title):
	# This function takes a pageid and 
	# returns the "printable"-URL of that
	# page/category
	command = "%s%s%s" % (mywiki, cmd_geturlfromID, the_title)
	mycontent = urllib2.urlopen(command)
	mydata = mycontent.read()
	mycontent.close()
	myxml  = ET.fromstring(mydata)
	output = myxml[0][0][0].get('editurl')
	output = output.replace("&action=edit", "&printable=yes")
	#the_title = urllib2.quote(the_title)
	#output = "%s/index.php?title=%s&printable=yes" % (mywiki, the_title)
	return(output);
	
#---- end of functions --------------
	




		
#### M A I N   S C R I P T
#-------------------------
print "\n\nCollecting data for %s \n\n" % (kategorie)

# Get pageid of start-category
the_url = "%s%s%s" % (mywiki, cmd_catinfo, kategorie)  	# built up URL
the_url = the_url.encode('utf-8') 					   	# encode URL to UTF-8
mycontent = urllib2.urlopen(the_url)					# open URL
mydata = mycontent.read()								# read Content
mycontent.close()										# close URL

data = ET.fromstring(mydata)
current_parent = getCategoryID(data)					# get "pagied" of startpoint


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
	
	#get pageid of current category
	current_parent = loop_id[y]
	the_url = "%s%s%s" % (mywiki, cmd_subcat, loop_list[y])
	the_url = the_url.encode('utf-8')
	mycontent = urllib2.urlopen(the_url)
	mydata = mycontent.read()
	mycontent.close()
	data = ET.fromstring(mydata)

	for child in data.iter('cm'):
		neuer_titel = child.get('title')
		neue_pageid = child.get('pageid')

	
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
 	current_level = current_level + 1;
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
options = {
    'page-size': 'A4',
    'margin-top': '0.5in',
    'margin-right': '0.5in',
    'margin-bottom': '0.5in',
    'margin-left': '0.5in',
    'encoding': "UTF-8",
    'no-outline': None
}


for f in the_prefix:
	prozente = round(artikelzaehler*100/gesamtzahl,3)
	print("Processing %s (%s of %s) / %s %%" % (the_names[artikelzaehler], (artikelzaehler+1), gesamtzahl, prozente) )

	# Getting printable URL
	pdf_url = wikiHTMLprint(the_pageids[artikelzaehler])
	
	# Getting PDF-Version of URL
	the_prefix_dummy = "%05d" % (artikelzaehler)
	the_filename = "%s-%s-%s_%s.mwcpdf.pdf" % (the_prefix_dummy, the_prefix[artikelzaehler], is_category[artikelzaehler], the_pageids[artikelzaehler])
	current_pdf = pdfkit.from_url(pdf_url, the_filename, options=options)
	
	# Reading into PdfFileReader
	current_pdf = PdfFileReader(open(the_filename, "rb"))
	
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
	output_pdf_name = "MWC2PDF-Output.pdf"
	output_pdf_file = open(output_pdf_name, "wb")
	output_pdf_stream.write(output_pdf_file)
finally:
	output_pdf_file.close()

print "%s successfully created." % output_pdf_name

# End printing into PDF-File
###############################################################



# http://superuser.com/questions/1009939/how-to-merge-pdfs-and-create-bookmarks-for-each-input-file-in-output-file-linu
# https://pypi.python.org/pypi/pdfkit/0.4.1
