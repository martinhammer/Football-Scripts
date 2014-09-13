#!/bin/bash

# path where files will be downloaded to
WDOWNLOAD_PATH="/home/martin/bin/downloads"
# path for publishing the file to web
WWEB_PATH="/usr/share/mini-httpd/html"
# human-readable timestamp
WDATETIME=`date +"%Y%m%d"`

# download the table file
wget -q -O $WDOWNLOAD_PATH/table.shtml http://news.bbc.co.uk/mobile/bbc_sport/football/competition/100/table/index.shtml

# create plain text version
grep '<h2><abbr title="Barclays Premier League"><span>Premier League</span></abbr></h2>' $WDOWNLOAD_PATH/table.shtml | sed -e 's/\(^.*<span>Premier League<\/span><\/abbr><\/h2> \)\(.*\)\(<span>Championship<\/span>.*$\)/\2/' | sed -e 's/\(^.*<\/thead> <tbody>\)\(.*\)\(<\/tbody> <\/table>\)\(.*$\)/\2/' | sed -e 's/<\/tr>/\n/g' | sed -e 's/<[^>]*>/\t/g' | tr -s '\t' '\t' | cut -sf 3,5,7,9,11,13,15,17 > $WDOWNLOAD_PATH/table.$WDATETIME

# create html version
echo -e "<html>\n<body style='font-family:monospace'>\n<table border=1>\n<tr><th>Pos</th><th>Team</th><th>P</th><th>W</th><th>D</th><th>L</th><th>GD</th><th>Pts</th></tr>" > $WDOWNLOAD_PATH/table.html
sed -e 's/^/<tr><td align="right">/' -e 's/\t/<\/td><td align="right">/g' -e 's/$/<\/td><\/tr>/' -e 's/<td align="right">/<td>/2' $WDOWNLOAD_PATH/table.$WDATETIME >> $WDOWNLOAD_PATH/table.html
echo -e "\n</table>\n</body>\n</html>" >> $WDOWNLOAD_PATH/table.html

# copy files to www folder
cp $WDOWNLOAD_PATH/table.html $WWEB_PATH

