#!/usr/bin/env python3
import os
import diaspy
import sys
########################################################
#
# This script posts pictures from a given directory
# to a given DIASPORA-Account. It posts one picture per round.
#
# Requires:
#		- python3
#		- diaspy   (do a manual install via https://github.com/marekjm/diaspy)
#
# Usage:
#		# script will fail if it is not called from picturefolder!!
#		$:>  cd /path/to/picturefolder							
# 		$:>  /path/to/pic2diaspora.py /path/to/picturefolder
#
# This script will create the file "0archive_posted.txt"
# in the given picture directory (check for write permission). In this textfile,
# filenames of pictures already posted are stored.
# This script won't upload any pictures included in "0archive_posted.txt"
# The script looks up all pictures in the given directory
# and compares their filenames with "0archive_posted.txt"
# The script will post the first "new" pictures it founds to Diaspora and exits. So, 
# one picture is posted per round. Thus, the script is ment to be run via cronjob.
#  # Cron.Example:
#  # post every 6 hours a picture
#  0 */6 * * * 	cd /path/to/picturefolder; /path/to/pic2diaspora.py /path/to/picturefolder
#
#---------------------------------------------
# 		CHANGE TO FIT YOUR SETTINGS
#---------------------------------------------
podurl 		= 'https://your.pod.org' 	# The URL of your account's pod
poduser 	= 'USERNAME'				# Username	
poduserpwd 	= 'SUPERSECRET'				# Password
standardmessage = '#cool #hashtags'		# message posted with each photo, e.g. "#nsfw"

#---------------------------------------------
#########################################################
# no need to change anything after here
#---------------------------------------------


# # #    M A I N    L O O P    # # # #
#---------------------------------------------
#
# check if the picture directory is set
picdir = sys.argv[1]
if len(picdir) < 1:
    print("Please specify picture directory")
    sys.exit()
elif picdir == ".":
	print("Please type full path to picture directory")
	sys.exit()
print('picture directory is %s' % (picdir))


# check if there is my archive_posted.txt in picture directory
archive_path = '%s/%s' % (picdir, '0archive_posted.txt')
print(archive_path)
ismylogthere = os.path.exists(archive_path)
if ismylogthere == False:
	print('creating my archive-log in %s' % (archive_path))
	f=open(archive_path,"w")
	f.close()


# read already posted pics from archive_posted.txt
archiveposted = open(archive_path).read()


# read all filenames in picture directory
pictures = os.listdir(picdir)
for pics in pictures:
	# check if this pic is really a pic
	if pics.lower().endswith(('.png', '.jpg', '.gif', '.jpe', '.jpeg')):
		# check if pic was already posted
		if pics in archiveposted:
			print('picture already posted: %s' % (pics))
		else:
			print('Ready to post new picture: %s' % (pics))
			pic_path = '%s/%s' % (picdir, pics)
			
			
			# post pic to diaspora
			print('Upload pic %s with path %s to Diaspora' % (pics, pic_path))
			connection = diaspy.connection.Connection(pod=podurl, username=poduser, password=poduserpwd)
			connection.login()
			token = repr(connection)
			stream = diaspy.streams.Stream(connection)
			stream.post(photo=pics, text=standardmessage)
			
			# write pic's filename to archive log
			f=open(archive_path,"a")
			f.write(pics)
			f.write('\n')
			f.close()
			break
	else:
		print('This file has no valid suffix: %s' % (pics))
print('\nDone!\n')
