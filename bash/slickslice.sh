#!/bin/bash
# http://slickslice.sourceforge.net/
# Copyright 2007,2008 mojoholder
# Distributed under the terms of the GNU General Public License, v2 or later
# slightly modified by produnis 02/2018

VERSION="0.9produnis"

# You can change your default slickslice options in
# ~/.slickslice-config file
# For more help: slickslice -h 

# GLOBAL VARIABLES
SCALENOTE=
WIDTH=
HASH=
QUOTE="'"

# Number of seconds between each screenshot in the timeline
# Leave void if you want an automatic screenshot rate calculation 
# [default: void]
#TIMESTEP=$TIMESTEP


function savedefaults()
{
echo "# Config file for SlickSlice $VERSION
# http://slickslice.sourceforge.net
# slickslice -h for more help

# The size of the timeline in WxH format where:
# W is the number of thumbs in a row
# H is the number of thumbs in a column
# [default: 4x15]  
DIMENSION=$DIMENSION

# Start thumbnails generation at this file position (seconds)
# [default: 10]
FIRSTFRAME=$FIRSTFRAME

# Custom font for the stats table
# Run 'identify -list font' for a list of available fonts
# For more info: www.imagemagick.org
# Or provide the path to the installed font directly.
# [default: "DejaVu-Sans-Condensed"]
CUSTOMFONT=$CUSTOMFONT

# Custom font color for the stats table
# Run 'identify -list color' for a list of available fonts
# For more info: www.imagemagick.org
# [default: Black]
FONTCOLOR=$FONTCOLOR

# Custom background color
# Run 'identify -list color' for a list of available color names
# For more info: www.imagemagick.org
# [default: #FFFFFF (White)]
BACKGROUNDCOLOR=$BACKGROUNDCOLOR

# Custom color of a thumbnail frame
# Run 'identify -list color' for a list of available color names
# For more info: www.imagemagick.org
# [default: #F0F0FF]
FRAMECOLOR=$FRAMECOLOR

# Do you need a 3 screenshots on one page image?
# [default: yes]
SCREENSHOTS=$SCREENSHOTS

# Generate shadows for thumbnails? 
# NOTE: soft shadows available since ImageMagick version 6.3.1
# [defaults: yes]
SHADOWS=$SHADOWS

# The name of a jpeg viewer program
# For KDE   - "kview" or "kuickshow" or other
# For GNOME - "eog" or "gthumb" or other
# [default: eog ]
VIEWPROGRAM=$VIEWPROGRAM

# Include the video filename in the stats table 
# [default: yes]
SHOWNAME=$SHOWNAME

# Delete all temp data on exit?
# [default: yes]
ERASE=$ERASE

# Default mplayer custom options
# [default: '-vf pp=ac/lb']
MPLAYER=$QUOTE$MPLAYER$QUOTE

# Jpeg quality
# [default: 100]
JPEGQUALITY=$JPEGQUALITY

# Show md5sum in the stats table?
# [default: no]
USEHASH=$USEHASH" > ~/.slickslice-config
}

function usage()
{
source ~/.slickslice-config
cat << EOF

USAGE: `basename $0` options

The program creates two jpeg files based on a videofile content:
a timeline view and 3 screenshots on a page.
For more info: http://slickslice.sourceforge.net

OPTIONS:
  -x  file       The name of a videofile to slickslice
  -m 'options'   Pass custom options to mplayer 
                 [default: '-vf pp=ac/lb']
                 Ex: Enable postproccessing filters for better image quality:
                     `basename $0` -x video.avi -m '-vf pp=lb/ac'
  -S  WxH        Set the timeline dimention
                 W - number of thumbs in a row
                 H - number of thumbs in a column
                 [default: $DIMENSION]
                 Ex: Create a timeline of 17 thumbs in one row:
                     `basename $0` -x video.avi -S 17x1 
  -w  width      Custom video width for automatic scale detection 
                 [default: auto]
                 Ex: Force `basename $0` to use width 1066px for scaling detection:
                     `basename $0` -x video.avi -w 1066
  -q  value      Custom jpeg quality (worst 1-100 best) 
                 [default: $JPEGQUALITY]
                 Ex: Set jpeg quality to 60:
                     `basename $0` -x video.avi -q 60
  -c  value      Custom color of a thumbnail frame. Run 'identify -list color' for a list
                 of available colors. For more info www.imagemagick.org 
                 [default: $FRAMECOLOR]
                 Ex: Set frame color to LightSkyBlue:
                     `basename $0` -x video.avi -c LightSkyBlue
  -b  value      Custom background color. Run 'identify -list color' for a list
                 of available colors. For more info www.imagemagick.org
                 [default: $BACKGROUNDCOLOR]
                 Ex: Set background color to LightGrey:
                     `basename $0` -x video.avi -b LightGrey

  -l  value      Custom font color. Run 'identify -list color' for a list
                 of available colors. For more info www.imagemagick.org
                 [default: $FONTCOLOR]
                 Ex: Set font color to White and background to Black:
                     `basename $0` -x video.avi -l White -b Black
  -f  fontname   Custom font. Run 'identify -list font' for a list of available fonts.
                 For more info www.imagemagick.org
                 Or provide the path to the installed font directly.
                 [default: $CUSTOMFONT]
                 Ex1: Let's use Bitstream-Vera-Sans-Bold
                     `basename $0` -x video.avi -f Bitstream-Vera-Sans-Bold
                 Ex2: Let's use our system font /usr/share/myfont.ttf
                     `basename $0` -x video.avi -f /usr/share/myfont.ttf

SWITCHES:
  -o   Turn off image shadows
  -e   Do not generate a 3 screenshots on a page image
  -d   Do not delete all temporary files on exit
  -s   Print md5sum hash into the info section of the timeline image
  -n   Hide the file name in the info section of the timeline image

NOTE:  Default values for switches can be overridden 
       by your config file ~/.slickslice-config

EXAMPLE: 
    Slickslice myvideo.avi. Run mplayer with postprocessing
    filters that improve the image quality. Include hash sum info.
    On exit keep all temporary files. Use LightPink color for thumbnail
    frames. Timeline dimension is 3 rows by 7 columns.

    `basename $0` -x ./myvideo.avi -m '-vf pp=lb/ac' -s -d -c LightPink -S 7x3

EOF
}

check_tools()
{

local RESULT=
local AREWEOK=1

echo "INFO: Looking for the programs SlickSlice depends on:"
echo -ne "INFO: "


for tool in {"convert","mplayer","montage","identify"}; do
	if [ "$RESULT" != "" ]; then echo -ne ", "; fi
	RESULT="`which "$tool" &> /dev/null`"
	if [ $? -eq "0" ]; then RESULT="found"; else RESULT="NOT found"; AREWEOK=0; fi
	echo -ne "'$tool' $RESULT"; 
done
echo

if [ "$AREWEOK" -eq 0 ]; then 
	echo "INFO: SlickSlice is powered by ImageMagick & Mplayer packages"
	echo "INFO: Please install them and try again."
	echo "ERROR: Cannot proceed as some programs were not found!"
	exit 10
fi

}


echo "VERSION: SlickSlice $VERSION"
echo 
check_tools


# slickslice defaults options

#TIMESTEP=
DIMENSION=6x5
FIRSTFRAME=10
CUSTOMFONT="DejaVu-Sans-Condensed"
FRAMECOLOR=#F0F0FF
BACKGROUNDCOLOR=White
FONTCOLOR=Black
SCREENSHOTS=no
SHADOWS=yes
VIEWPROGRAM=
SHOWNAME=yes
ERASE=yes
MPLAYER='-vf pp=ac/lb'
JPEGQUALITY=100
USEHASH=no

if [ ! -f ~/.slickslice-config ]; then
	echo "INFO: The config file does not exist!"
	savedefaults
	if [ $? -eq 0 ]; then
		echo "INFO: Created a new config file"
	else
		echo "ERROR: Could not create a config file!"
		exit 10
	fi
fi

# user's config options

source ~/.slickslice-config

# update config file to a new slickslice version

CONFIGVER=`grep -e "# Config file for SlickSlice " ~/.slickslice-config | sed -e 's/# Config file for SlickSlice //g'`
if [ "$CONFIGVER" != "$VERSION" ]; then
	echo "INFO: You have an old version config file"
	echo "INFO: Updating your config file up to $VERSION version"
	BACKUPDCONFIG=~/.slickslice-config.old.v$CONFIGVER
	COUNTER="ok"
	if [ -f $BACKUPDCONFIG ]; then
		COUNTER=0
		while [ $COUNTER -le 8 ]; do
			let COUNTER+=1
			BACKUPDCONFIG=~/.slickslice-config.old.v$CONFIGVER-$COUNTER
			if [ ! -f $BACKUPDCONFIG ]; then 
				COUNTER="ok"
				break
			fi
		done
	fi
	if [ "$COUNTER" != "ok" ]; then
		echo "WARN: Cannot backup your current config file" 
		echo "WARN: Please manually backup and then delete it" 
		exit 10
	fi
	mv ~/.slickslice-config $BACKUPDCONFIG
	if [ $? -eq 0 ]; then
		echo "INFO: Your old config saved as $BACKUPDCONFIG"
	else
		echo "ERROR: Could not create a backup file $BACKUPDCONFIG"
		exit 10
	fi
	savedefaults
fi

while getopts “oendshc:x:m:w:q:b:f:S:l:” OPTION
do
     case $OPTION in
         x)
             FULLPATHNAME="$OPTARG"
			 echo "USER: SlickSlicing \"$FULLPATHNAME\""
             ;;
         m)
             MPLAYER="$OPTARG"
             if [ "${MPLAYER:0:1}" != "-" ]; then MPLAYER="-$MPLAYER"; fi
			 echo "USER: Custom mplayer option(s): $MPLAYER"
             ;;
         w)
			 echo "USER: Custom video width for scale calculation: $OPTARG"
             WIDTH="$OPTARG"
             ;;
         S)
			 echo "USER: Timeline dimension: $OPTARG"
             DIMENSION="$OPTARG"
             ;;
         q)
			 echo "USER: JPEG quality: $OPTARG"
             JPEGQUALITY="$OPTARG"
             ;;
         c)
			 echo "USER: Selected frame color: $OPTARG"
             FRAMECOLOR="$OPTARG"
             ;;
         b)
                         echo "USER: Selected background color: $OPTARG"
             BACKGROUNDCOLOR="$OPTARG"
             ;;

         l)
                         echo "USER: Selected font color: $OPTARG"
             FONTCOLOR="$OPTARG"
             ;;
         s)
			 echo "USER: Calculate and include md5sum"
             USEHASH=yes
             ;;
         f)
			 echo "USER: Selected font $OPTARG"
             CUSTOMFONT="$OPTARG"
             ;;
         d)
			 echo "USER: Keep all temporary files on exit"
             ERASE=no
             ;;
         n)
			 echo "USER: The name of the video file will be hidden"
             SHOWNAME=no
             ;;
         o)
			 echo "USER: Turn off image shadows"
             SHADOWS=no
             ;;
         e)
			 echo "USER: Do not generate a 3 screenshots on a page image"
             SCREENSHOTS=no
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

echo ""


if [[ -z "$FULLPATHNAME" ]]; then
	usage
	echo "ERROR: What videofile do you want to slickslice?"
	exit 0
fi


RESULT=`identify -list font | grep "$CUSTOMFONT" 2>&1 `
if [ "$RESULT" != "" ]; then 
	CUSTOMFONT="-font $CUSTOMFONT"
	else
           if [ -e "$CUSTOMFONT" ]; then
               CUSTOMFONT="-font $CUSTOMFONT"
               else
		echo "WARN: Custom font $CUSTOMFONT was not found"
		echo "WARN: Default font will be used."
		echo "HINT: run 'identify -list font' for a list of all available fonts"
		echo "HINT: or install the font package with $CUSTOMFONT"
		CUSTOMFONT=
	   fi
fi


if  [[ "${FULLPATHNAME:0:1}" == "/" ]]; then
	echo -ne ""
else 
	if [[ "${FULLPATHNAME:0:2}" == "./" ]]; then
		FULLPATHNAME=`pwd`/${FULLPATHNAME:2}
	else
		FULLPATHNAME=`pwd`/$FULLPATHNAME
	fi
fi

	echo "INFO: Examining $FULLPATHNAME"

if [ ! -f "$FULLPATHNAME" ]; then
	echo "INFO: The file does not exist!"
	echo "ERROR: No file to slickslice :("
	exit 10
fi

echo "INFO: `file -b -i "$FULLPATHNAME"`"

playtime=`mplayer -vo null -ao null -frames 0 -identify "$FULLPATHNAME" 2>/dev/null |\
 sed -ne '/^ID_/ { s/[]()|&;<>\`'"'"'\\!$" []/\\&/g;p }' |\
 grep --color=never '^ID_LENGTH=[.0-9]*' | sed -e 's/ID_LENGTH=//g'`

video_width=`mplayer -vo null -ao null -frames 0 -identify "$FULLPATHNAME" 2>/dev/null |\
 sed -ne '/^ID_/ { s/[]()|&;<>\`'"'"'\\!$" []/\\&/g;p }' |\
 grep --color=never '^ID_VIDEO_WIDTH=[.0-9]*' | sed -e 's/ID_VIDEO_WIDTH=//g'`

if [ "$video_width" == "" ]; then
video_width=`mplayer -vo null -ao null -frames 0 -identify "$FULLPATHNAME" 2>/dev/null |\
 sed -ne '/^ID_/ { s/[]()|&;<>\`'"'"'\\!$" []/\\&/g;p }' |\
 grep --color=never '^ID_VIDEO_WIDTH=[.0-9]*' | sed -e 's/ID_VIDEO_WIDTH=//g'`
	echo "INFO: Movie image width is undefined"
	echo "WARN: Is this a videofile at all?"
	echo "ERROR: No video to slickslice :("
	exit 10
fi

playtime=${playtime/.*} 
video_width=${video_width/.*} 

if [ $playtime -le 0 ]; then
	echo "INFO: The movie duration reported by MPlayer: $playtime seconds"
	echo "ERROR: The movie is too short"
	echo "ERROR: This video cannot be slicksliced :("
	exit 10
fi

# AUTOMATIC SCALING 
# the final image width should be aprx 680px
if [ $[$WIDTH+0] -eq 0 ]; then
	SCALE=$[16700/$video_width]"%"
else
	SCALE=$[16700/$WIDTH]"%"
	SCALENOTE="( using userdefined width $WIDTH px)"
fi

echo "INFO: Movie duration: $playtime seconds"
echo "INFO: Movie width: $video_width pixels"

DIMW=${DIMENSION/x*}
DIMH=${DIMENSION/*x}
echo "INFO: Timeline dimension: WxH=\"$DIMENSION\" -> W=\"$DIMW\" H=\"$DIMH\""

if [[ `echo $DIMW | sed -e 's|[0-9]||g'` != "" ]] || \
   [[ `echo $DIMH | sed -e 's|[0-9]||g'` != "" ]]; then
	echo "ERROR: Wrong timeline dimension format!"
	exit 10
fi

#if [ "$TIMESTEP" != "" ] && [ $TIMESTEP -eq 0 ]; then
#	echo "ERROR: Selected thumb generation frame rate equals zero!"
#	exit 10
#fi

TOTALTHUMBS=$[$DIMW*$DIMH]

if [ "$TIMESTEP" == "" ]; then
	TIMESTEP=$[($playtime-$FIRSTFRAME)/($TOTALTHUMBS)]
	#if [[ $TIMESTEP -le 15 ]]; then TIMESTEP=$[$playtime/16]; fi
	if [[ $TIMESTEP -eq 0 ]]; then 
		echo "ERROR: Cannot generate $TOTALTHUMBS thumbs for a short movie!"
		echo "INFO:  The estimated maximum number of thumbs is $[$playtime-$FIRSTFRAME-5]"
		exit 10
	fi
	echo "AUTO: Scaling set automatically to $SCALE $SCALENOTE"
	echo "AUTO: A thumb generation frame rate: one in $TIMESTEP seconds"
	echo "AUTO: Total number of thumbs in the timeline: "$[($playtime-$FIRSTFRAME)/$TIMESTEP]
else
	echo "USER: Selected thumb frame rate generation: one in $TIMESTEP seconds."
	echo "USER: Total number of thumbs in the timeline: "$[($playtime-$FIRSTFRAME)/$TIMESTEP]
fi

MOVIENAME=`basename "$FULLPATHNAME"`
COUNTER=$FIRSTFRAME
MASK="000000"
TIMEMASK="00"
TEMPDIR="/tmp/slickslicetmp-$USER/$MOVIENAME/"

mkdir -p "$TEMPDIR" &> /dev/null
chmod og-rwx "/tmp/slickslicetmp-$USER/"
rm "$TEMPDIR/"* -Rf &> /dev/null
pushd "$TEMPDIR" &> /dev/null


# Check MPlayer for possible options errors

WARNINGS=0
mplayer -ao null "$FULLPATHNAME" -vo jpeg:outdir=./screenshots $MPLAYER -ss 5 -frames 1  &> ./slickslicemplayer.log
MPLAYERTEST="`cat ./slickslicemplayer.log | sed -e 's/Failed to open LIRC support.//g' | grep -e Error -e FATAL -e error -e 'Failed to open'`"

if [[ "$MPLAYERTEST" != "" ]] ; then
	echo 
	echo "INFO: Mplayer Log"
	cat ./slickslicemplayer.log | sed -e 's/^/LOG: /g'
	echo
	cat ./slickslicemplayer.log | grep -e Error -e FATAL -e error
	echo "ERROR: Mplayer reported a problem!"
	echo "ERROR: Please check the slickslicemplayer.log and fix it."
	exit 10
fi

FRAMECOUNTER=1
while [ $COUNTER -le "$playtime" ] && [ $FRAMECOUNTER -le $TOTALTHUMBS ] 
do 
	mplayer -ao null -vf pp=ac $MPLAYER -vo jpeg:outdir=./screenshots -ss $COUNTER -frames 1 "$FULLPATHNAME" &>/dev/null
	if [ ! -f ./screenshots/00000001.jpg ]; then let $((WARNINGS+=1)); fi
	mv ./screenshots/00000001.jpg ./screenshots/${MASK:${#COUNTER}}$COUNTER.jpg 2>/dev/null 1> /dev/null
	echo -ne "\033[200D"
	echo -ne "\033[K"
	echo -ne "INFO: Capturing a movie frame @ $COUNTER seconds"
	let $((COUNTER+=$TIMESTEP))
	let $((FRAMECOUNTER+=1))
done 
	echo -ne "\033[200D"
	echo -ne "\033[K"
	echo "INFO: Finished screenshots generation."
	if [ ! $WARNINGS -eq 0 ]; then
		echo "WARN: *** Some files cannot be properly seeked by mplayer"
		echo "WARN: *** Generation of $WARNINGS screenshot(s) failed!"
		echo "WARN: *** Timeline may NOT be a complete videofile presentation"
	fi

mkdir ./thumbs 2> /dev/null
mkdir ./labeledthumbs 2> /dev/null
rm ./thumbs/* -f 2> /dev/null
rm ./labeledthumbs/* -f 2> /dev/null

ls -1 ./screenshots/*.jpg | while read jpgfile; do 
	thumbfile=`basename "$jpgfile"`
	echo -ne "\033[200D"
	echo -ne "\033[K"
	echo -ne "INFO: Scaling $thumbfile into $thumbfile"
	convert "$jpgfile" -scale "$SCALE" ./thumbs/thumb_"$thumbfile"
done
	echo -ne "\033[200D"
	echo -ne "\033[K"
	echo "INFO: Finished making thumbnails."


ls -1 ./thumbs/*.jpg | while read longfile; do
	JPGFILE=`echo "$longfile" | sed -e 's/.\/thumbs\///g'`
	NUMFILE=`echo "$JPGFILE"  | sed -e 's/.jpg//g' -e 's/thumb_//g'`

	TIMEVALUE=$((10#$NUMFILE+0))		
	MINUTEZ=$[($TIMEVALUE-(($TIMEVALUE+0)/60/60)*60*60)/60]
	HOURZ=$[($TIMEVALUE+0)/60/60]
	SECONDZ=$[$TIMEVALUE-$HOURZ*60*60-$MINUTEZ*60]
	MINUTEZ=${TIMEMASK:${#MINUTEZ}}$MINUTEZ
	SECONDZ=${TIMEMASK:${#SECONDZ}}$SECONDZ
	TIMELABLE="$HOURZ:$MINUTEZ:$SECONDZ"
	LABLE="$TIMELABLE"
	echo -ne "\033[200D"
	echo -ne "\033[K"
	echo -ne "INFO: Adding label \"$TIMELABLE\" to $JPGFILE "
	montage -geometry +1+1 -background "$FRAMECOLOR" \
	-label "$LABLE" $CUSTOMFONT -pointsize 9 "./thumbs/$JPGFILE" "./labeledthumbs/$NUMFILE.jpg"
done
	echo -ne "\033[200D"
	echo -ne "\033[K"
	echo "INFO: Finished adding labels to the thumbnails."

#################################

if [ "$SHADOWS" == "yes" ]; then
	SHADOWS_OPTION="-shadow"
	else
	SHADOWS_OPTION=""
fi

echo -ne "INFO: Creating a timeline image..."
montage $SHADOWS_OPTION -background "$BACKGROUNDCOLOR" -geometry +3+3 -tile $DIMHx$DIMW ./labeledthumbs/*.jpg thumb_panel.jpg
echo "done"

mplayer "$FULLPATHNAME" -ao null -endpos 0 -vo null 2>/dev/null > movieinfo
FILESIZE=`ls "$FULLPATHNAME" -Hsh --block-size=1048576 | grep "^[0-9]*" -o`"M"
	TIMEVALUE=$((10#$playtime+0))		
	MINUTEZ=$[($TIMEVALUE-(($TIMEVALUE+0)/60/60)*60*60)/60]
	HOURZ=$[($TIMEVALUE+0)/60/60]
	SECONDZ=$[$TIMEVALUE-$HOURZ*60*60-$MINUTEZ*60]
	MINUTEZ=${TIMEMASK:${#MINUTEZ}}$MINUTEZ
	SECONDZ=${TIMEMASK:${#SECONDZ}}$SECONDZ
	TIMELABLE="$HOURZ:$MINUTEZ:$SECONDZ"
DURATION="$TIMELABLE" 

VIDEO=`cat movieinfo | grep VIDEO\: | sed -e 's/VIDEO:  //g'`
AUDIOSTATS=`cat movieinfo | grep AUDIO\: | sed -e 's/AUDIO://g'`
AUDIOCODEC=`mplayer -vo null -ao null -frames 0 -identify "$FULLPATHNAME" 2>/dev/null |\
 sed -ne '/^ID_/ { s/[]()|&;<>\`'"'"'\\!$" []/\\&/g;p }' |\
 grep --color=never '^ID_AUDIO_FORMAT=*' | sed -e 's/ID_AUDIO_FORMAT=//g'`

if [ "$AUDIOCODEC" == "85" ]; then
	AUDIOCODEC="MP3"
fi

if [ "$AUDIOSTATS" == "" ]; then
	AUDIOSTATS="no sound"
fi

if [ "$USEHASH" == "yes" ]; then
	echo -ne "INFO: Calculating hashsum..."
	HASH=`md5sum "$FULLPATHNAME" | grep -o '^[0-9 a-z]* ' | sed -e 's/\ //g'`
	echo "done"
fi

echo 
echo "INFO: Name $MOVIENAME"
echo "INFO: Filesize $FILESIZE"
echo "INFO: Video $VIDEO"
echo "INFO: Audio [$AUDIOCODEC] $AUDIOSTATS"
echo "INFO: Duration $DURATION"
if [ "$HASH" != "" ]; then echo "INFO: Hash $HASH"; fi
echo ""
echo "INFO: JPEG Quality set to $JPEGQUALITY"

MOVIENAME_FIXED=`echo $MOVIENAME | sed -e 's/\d39/\^/g'`
if [ "$SHOWNAME" == "no" ]; then
	MOVIENAME_FIXED="`echo $MOVIENAME_FIXED | sed -e 's/./X/g'`"
fi

convert  thumb_panel.jpg -gravity NorthWest -background "$BACKGROUNDCOLOR" $CUSTOMFONT -fill $FONTCOLOR -pointsize 13 -splice 0x85  \
-draw "text 15,5 'NAME:  $MOVIENAME_FIXED'" \
-draw "text 15,25 'VIDEO: $VIDEO'"  \
-draw "text 15,45 'AUDIO: [$AUDIOCODEC] $AUDIOSTATS'" \
-draw "text 15,65 'DURATION: $DURATION'"  \
-gravity NorthEast -draw "text 15,65 '$HASH'" \
-draw "text 15,5 'SIZE: $FILESIZE'" \
final_result.jpg

convert final_result.jpg -quality $JPEGQUALITY final.jpg

popd &>/dev/null

convert "$TEMPDIR/final.jpg" $CUSTOMFONT -pointsize 9 -gravity SouthEast \
-background "$BACKGROUNDCOLOR" -splice 0x11 -draw "text 0,0 'slicksliced! - powered by imagemagick & mplayer - running on linux  '" \
"./$MOVIENAME-preview.jpg"

if [[ "$SCREENSHOTS" == "yes" ]]; then
	NUMSCREENSHOTS=`ls -1 "$TEMPDIR/screenshots/"* | wc -l`
	SCREENSTEP=$[$NUMSCREENSHOTS/3]
	#SSB=$[$NUMSCREENSHOTS/2]
	#SSC=$[$SSB+$SSB/2]
	#SSA=$[$SSB-$SSB/2]

        SSA=$SCREENSTEP
        SSB=$[SCREENSTEP*2]
        SSC=$[SCREENSTEP*3]
	
	if [ $SSA -eq 0 ]; then 
		SSA=1
		SSB=1
		SSC=1
	fi

	COUNTER=1

	ls -1 "$TEMPDIR/screenshots/"* | while read temp
	do
		if [[ "$COUNTER" -eq "$SSA" ]]; then echo "$temp" > "$TEMPDIR/screenshot.1";  fi
		if [[ "$COUNTER" -eq "$SSB" ]]; then echo "$temp" > "$TEMPDIR/screenshot.2";  fi
		if [[ "$COUNTER" -eq "$SSC" ]]; then echo "$temp" > "$TEMPDIR/screenshot.3"; break; fi
		let $[COUNTER+=1]
	done

	echo -ne "INFO: Generating 3x fullsize screenshot preview..."
	montage $SHADOWS_OPTION -background "$BACKGROUNDCOLOR" -geometry +5+5 -tile 1x \
	"`cat "$TEMPDIR/screenshot.1"`"  "`cat "$TEMPDIR/screenshot.2"`" "`cat "$TEMPDIR/screenshot.3"`" "$TEMPDIR/fullsize_preview.jpg"

	convert "$TEMPDIR/fullsize_preview.jpg" $CUSTOMFONT -pointsize 9 -gravity SouthEast \
	-background "$BACKGROUNDCOLOR" -splice 0x11 -draw "text 0,0 'slicksliced! - powered by imagemagick & mplayer - running on linux  '" \
	"$TEMPDIR/SCREENSHOTS_$MOVIENAME.jpg"
	convert "$TEMPDIR/SCREENSHOTS_$MOVIENAME.jpg" -quality $JPEGQUALITY "./SCREENSHOTS_$MOVIENAME.jpg"

	echo "done"
fi

echo "INFO: The file was successfully SlickSliced!"
if [ "$ERASE" == "yes" ]; then
	echo -ne "INFO: Deleting all temporary files..."
	rm -Rf "$TEMPDIR"
	echo "done"
fi

which $VIEWPROGRAM &> /dev/null
if [  $? -eq 0 ]; then
		echo "INFO: Launching the preview program."
		if [ "$SCREENSHOTS" == "yes" ]; then
			$VIEWPROGRAM "SCREENSHOTS_$MOVIENAME.jpg" &
		fi
		$VIEWPROGRAM "$MOVIENAME-preview.jpg" &
	else
		echo "WARN: Selected jpeg viewer '$VIEWPROGRAM' is not available."
		echo "WARN: Please change this option in your slickslice config file:"
		echo "WARN: ~/.slickslice-config to the jpeg viewer program installed"
		echo "WARN: on this computer"
fi

echo "INFO: Have a nice day!"
