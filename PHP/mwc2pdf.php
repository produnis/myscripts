<?php
## Welcome to mwc2pdf
## ----------------------------------------------
## Media Wiki Category To PDF (MWC2PDF)
## is a php script that exports a Category from MediaWiki
## into PDF, including all Pages of that category as well as 
## all pages from subcategories.
## mwc2pdf uses MediaWiki's  "api.php" to collect 
## all data and create a "pagetree".
## mwc2pdf prints out every item of that pagetree 
## into a single pdf-file using "wkhtmltopdf".
## It than combines all single pdf-files into 
## one single pdf-file called "MWC2PDF.pdf" using "pdftk".
##
## -----------------------------------------------
## Requires:
## - PHP >= 5.4
## - wkhtmltopdf
## - pdftk
## -------------------------
## Written by Joe Slam 2015
## Licence: GPL
## -------------------------
##
## Usage:
## 1) Change the three lines to fit your situation
## 2) open terminal
## 3) $ php /PATH/TO/mwc2pdf.php #
##           
## All files are generated in the directory you call mwc2pdf from
##
####################################################################


# + + + + + + + + + + + + + + + + + + + + + + +
## Change this vars to fit your system
$mywiki = "http://192.168.0.2/produniswiki/"; // URL to index.php
$kategorie = "Kategorie:Hauptkategorie"; // Which Category to grab?
$kategorie_word = "Kategorie:";          // What is "Category:" in your wiki's language?
# + + + + + + + + + + + + + + + + + + + + + + +


# ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  ! ! ! !
## Dont change after here...
# ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  ! ! ! !
##----------------------------------------------
## API -Commands
#------------------
# List all Subcategories
$cmd_subcat = "api.php?action=query&format=xml&list=categorymembers&cmlimit=5000&cmtitle=";
# List all Pages of Category
$cmd_catinfo = "api.php?action=query&format=xml&prop=categoryinfo&titles=";
# Get URL from pageid
$cmd_geturlfromID = "api.php?action=query&format=xml&inprop=url&prop=info&pageids=";

# Functions
#-------------------
	
#-----------------------------------------------------------------------	
function getCategoryID($xml){
	# this function returns the pageid of a category
	$arr=$xml->query[0]->pages[0]->page->attributes();
		#echo $arr["pageid"] . ": ";
		#echo $arr["title"] . "\n";
	return($arr["pageid"]);
	}
#-----------------------------------------------------------------------



#-----------------------------------------------------------------------	
function startsWith($haystack, $needle)
{	 # this function checks if the string 
	 # "$hayshack" starts with the letters "$neddle"
     $length = strlen($needle);
     return (substr($haystack, 0, $length) === $needle);
}
#-----------------------------------------------------------------------

function wikiHTMLprint($command){
	# This function takes a pageid and 
	# returns the "printable"-URL of that
	# page/category
	$xml = simplexml_load_file($command);
	$arr = $xml->query[0]->pages[0]->page->attributes();
	$output= str_replace("&action=edit", "&printable=yes", $arr['editurl']);
	return($output);
	}
#---- end of functions --------------
		
		


		
#### M A I N   S C R I P T
#-------------------------
echo "\n\nCollecting data for " . $kategorie ."\n\n";

# Get pageid of start-category
$xml = simplexml_load_file($mywiki . $cmd_catinfo . $kategorie);
$current_parent  = getCategoryID($xml);

# Setting up all important vars() and arrays()
#---------------------------------------------
$x 					= 0;
$y 					= 0;
$done 				= FALSE;
$the_pageids 		=  NULL;
$the_names 			=  NULL;
$loop_list 			= NULL;
$next_level 		= 0;
$current_level 		= 0;
$the_pageids[0]   	= $current_parent;
$the_names[0]     	= $kategorie;
$the_prefix[0]    	= "p0_";
$the_parentid[0]  	= 0;
$the_level[0]	  	= 0;
$is_category[0]	  	= "C";
$loop_list[0]     	= $kategorie;
$loop_id[0]		  	= $current_parent;
$loop_prefix[0]   	= "p0_";
//---------------------------------

$x++;



# MAIN LOOP
#----------------------
while ($done == FALSE){

	// get pageid of current category
	$current_parent = $loop_id[$y];
	
	# getting members of this category
	//-------------------------------------------------------------
	$xml = simplexml_load_file($mywiki . $cmd_subcat . $loop_list[$y]);
	foreach($xml->query[0]->categorymembers[0]->cm as $child){
		$arr = $child->attributes();
		#echo $arr["pageid"] . ": ";
		#echo $arr["title"] . "\n";
		
		// is this a Page?
		//---------------------------------------------------
        if(startsWith($arr["title"], $kategorie_word) == FALSE){
			if( 
				(startsWith($arr["title"], "Datei:") == FALSE) AND
				(startsWith($arr["title"], "File:")  == FALSE) AND
				(startsWith($arr["title"], "Media:")  == FALSE) AND
				(startsWith($arr["title"], "Bild:")  == FALSE)
			  ){
				// is page already in list?
				if(in_array("" . $arr["title"] . "", $the_names)){
					#echo "page " . $arr["title"] . " already in list \n";			
				}else{
					#echo "new Page";
					$the_pageids[$x]  = $arr["pageid"];
					$the_names[$x]    = $arr["title"];
					$the_parentid[$x] = $current_parent;
					$the_level[$x] 	  = $current_level;
					$the_prefix[$x]   = $loop_prefix[$y] . sprintf('%05d',$x);
					$is_category[$x]  = "P";
				}
			}else{ 				$x--; 				}
		//----------------------------------------------------
			
		// is this a Category?	
		//----------------------------------------------------
		}elseif(startsWith($arr["title"], $kategorie_word) == TRUE){
			// is Category already in list?
		    if(in_array("" . $arr["title"] . "", $the_names)){
				#echo "cat " . $arr["title"] . " already in list \n";	
			}else{
				#echo "new Category";
				$loop_list[] 	  = $arr["title"];
				$loop_id[] 		  = $arr["pageid"];
				$loop_prefix[] 	  = $loop_prefix[$y] . sprintf('%05d',$x) . "_";
				$the_pageids[$x]  = $arr["pageid"];
				$the_names[$x]    = $arr["title"];
				$the_prefix[$x]   = $loop_prefix[$y] . sprintf('%05d',$x) . "_";
				$the_parentid[$x] = $current_parent;
				$the_level[$x] 	  = $current_level+1;
				$is_category[$x]  = "C";
			}
		}
		//----------------------------------------------------
			
		$x++;
		
 	} // END foreach
 	$y++;
 	$current_level++;
 	if($y == sizeof($loop_list)+2){
		$done=TRUE;
	}
	//--------------------------------------------------------------

} // End WHILE false
// END Main Loop
#############################################################################




# # # #  S O R T    D A T A # # # # # # #
#--------------------------------------------
array_multisort($the_prefix, $the_pageids, $the_names, $the_parentid, $the_level,$is_category);
#--------------------------------------------
# # # # # # # # # # # # # # # # # # # # #




#--- output final array ---
echo "\nThis is what I got:\n";
$i = count($the_prefix);
echo $i;
for ($x =0;$x < $i; $x++){
	echo $the_prefix[$x] . "|" . $is_category[$x] . "| ". $the_pageids[$x] . ": " . $the_names[$x] . " | Lev=" . $the_level[$x] . " (P=" . $the_parentid[$x] . ")\n"; 
	}
#--------------------------------------------



## print PDF of Cats and Pages
## depends:   wkhtmltopdf
#---------------------------------------------
echo "\nPrinting single Pages to PDF (wkhtmltopdf)\n";
$i = count($the_prefix);
echo "\n";
for ($x =0;$x < $i; $x++){
	$command = $mywiki . "" . $cmd_geturlfromID . "" . $the_pageids[$x];
	$this_pdf = wikiHTMLprint($command);
	echo "Printing pageid " . $the_pageids[$x] . " | (" . $x . "/" . $i . ")\n";
	$command = "wkhtmltopdf '" . $this_pdf . "' " . sprintf('%06d',$x) . "-" . $the_prefix[$x] . "-" . $is_category[$x] . "_" . $the_pageids[$x] . ".mwc2pdf.pdf";
	$out = shell_exec($command); 
	echo "\n";
	}
#---------------------------------------------
 

## cats the PDFs into a single one
## depends:    pdftk
#---------------------------------------------
# $dummy = shell_exec("wkhtmltopdf http://google.com google.pdf");
echo "\nGenerating single PDF-file (pdftk)\n";
$command = "pdftk *.mwc2pdf.pdf cat output MWC2PDF.pdf";
$out = shell_exec($command);
## -------------------------------------------------------

echo "\nDone.\n";
?>
