#!/bin/bash

# path where files will be downloaded to
WDOWNLOAD_PATH="/home/martin/bin/downloads"
# path for publishing the file to web
WWEB_PATH="/usr/share/mini-httpd/html"
# URL to download
WWEB_URL="http://m.bbc.co.uk/sport/football/teams/chelsea/fixtures"
# base URL for getting the second file
WWEB_BASE="http://m.bbc.co.uk"

# download the fixtures file
wget -q -O $WDOWNLOAD_PATH/fixtures.shtml $WWEB_URL
# the fixtures file contains only the current month, so we get the next month file as well
wget -q -O $WDOWNLOAD_PATH/fixtures2.shtml $WWEB_BASE`grep "Currently viewing:" $WDOWNLOAD_PATH/fixtures.shtml | sed -e 's/\(^.*Currently viewing: <\/span>\)\(.*<\/span>  <a href=\"\)\(.[^\"]*\)\(\".*$\)/\3/'`

# process the two files
grep '<div data-istats-container="football-fixture-list" class="mod football-fl">' $WDOWNLOAD_PATH/fixtures.shtml | tr -s ' ' ' ' | sed -e 's/\(^.*<\/p> <\/div> \)\(.*\)\(<div class="mod outer-inner alert">.*$\)/\2/' | sed -e 's/<\/div> <\/div>/\n/g' | sed -e 's/<[^>]*>/\t/g' | sed -e 's/ \t/\t/g' | tr -s '\t' '\t' | cut -sf 2,3,4,5,6,7,8 > $WDOWNLOAD_PATH/fixtures
grep '<div data-istats-container="football-fixture-list" class="mod football-fl">' $WDOWNLOAD_PATH/fixtures2.shtml | tr -s ' ' ' ' | sed -e 's/\(^.*<\/p> <\/div> \)\(.*\)\(<div class="mod outer-inner alert">.*$\)/\2/' | sed -e 's/<\/div> <\/div>/\n/g' | sed -e 's/<[^>]*>/\t/g' | sed -e 's/ \t/\t/g' | tr -s '\t' '\t' | cut -sf 2,3,4,5,6,7,8 >> $WDOWNLOAD_PATH/fixtures

# create html version
echo -e "<html>\n<body style='font-family:monospace'>\n<table border=1>\n<tr><th>Date</th><th>Competition</th><th colspan='3'>Match</th><th colspan='2'>Time</th></tr>" > $WDOWNLOAD_PATH/fixtures.html
sed -e 's/^/<tr><td>/' -e 's/\t/<\/td><td>/g' -e 's/$/<\/td><\/tr>/' $WDOWNLOAD_PATH/fixtures >> $WDOWNLOAD_PATH/fixtures.html
echo -e "\n</table>\n</body>\n</html>" >> $WDOWNLOAD_PATH/fixtures.html

# copy files to www folder
cp $WDOWNLOAD_PATH/fixtures $WWEB_PATH
cp $WDOWNLOAD_PATH/fixtures.html $WWEB_PATH
