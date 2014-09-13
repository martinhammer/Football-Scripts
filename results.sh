#!/bin/bash

# path where files will be downloaded to
WDOWNLOAD_PATH="/home/martin/bin/downloads"
# path for publishing the file to web
WWEB_PATH="/usr/share/mini-httpd/html"
# URL to download
WWEB_URL="http://m.bbc.com/sport/football/teams/chelsea/results"
# base URL for getting the second file
WWEB_BASE="http://m.bbc.co.uk"

# download the results file
wget -q -O $WDOWNLOAD_PATH/results.shtml $WWEB_URL
# the results file contains only the current month, so we get the previous month file as well
wget -q -O $WDOWNLOAD_PATH/results2.shtml $WWEB_BASE`grep "Currently viewing:" $WDOWNLOAD_PATH/results.shtml | sed -e 's/\(^.*Next month unavailable\)\(.*<\/span>   <a href=\"\)\(.[^\"]*\)\(\".*$\)/\3/'`

# process the two files
grep '<div data-istats-container="football-fixture-list" class="mod football-fl">' $WDOWNLOAD_PATH/results.shtml | tr -s ' ' ' ' | sed -e 's/\(^.*<\/p> <\/div> \)\(.*\)\(<div class="mod outer-inner alert">.*$\)/\2/' | sed -e 's/<\/div> <\/div>/\n/g' | sed -e 's/<[^>]*>/\t/g' | tr -s '\t' '\t' | cut -sf 4,7,14,16,23,25,30 > $WDOWNLOAD_PATH/results
grep '<div data-istats-container="football-fixture-list" class="mod football-fl">' $WDOWNLOAD_PATH/results2.shtml | tr -s ' ' ' ' | sed -e 's/\(^.*<\/p> <\/div> \)\(.*\)\(<div class="mod outer-inner alert">.*$\)/\2/' | sed -e 's/<\/div> <\/div>/\n/g' | sed -e 's/<[^>]*>/\t/g' | tr -s '\t' '\t' | cut -sf 4,7,14,16,23,25,30 >> $WDOWNLOAD_PATH/results

# reorder the columns to make it pretty
sed -i -e 's/\(^[^\t]*\)\t\([^\t]*\)\t\([^\t]*\)\t\([^\t]*\)\t\([^\t]*\)\t\([^\t]*\)\t\([^\t]*\)/\1\t\2\t\3\t\4 - \6\t\5\t\7/' $WDOWNLOAD_PATH/results

# create html version
echo -e "<html>\n<body style='font-family:monospace'>\n<table border=1>\n<tr><th>Date</th><th>Competition</th><th colspan='3'>Score</th><th>FT</th></tr>" > $WDOWNLOAD_PATH/results.html
sed -e 's/^/<tr><td>/' -e 's/\t/<\/td><td>/g' -e 's/$/<\/td><\/tr>/' -e 's/<td><\/td>/<td>\&nbsp;<\/td>/g' $WDOWNLOAD_PATH/results >> $WDOWNLOAD_PATH/results.html
echo -e "\n</table>\n</body>\n</html>" >> $WDOWNLOAD_PATH/results.html

# copy files to www folder
cp $WDOWNLOAD_PATH/results $WWEB_PATH
cp $WDOWNLOAD_PATH/results.html $WWEB_PATH
