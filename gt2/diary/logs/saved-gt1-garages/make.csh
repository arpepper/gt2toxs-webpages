#!/bin/csh -f
cd /home/arpepper/public_html/gt2/diary/logs/saved-gt1-garages
foreach g ( `cat gt1-gamelist.txt` )
	../garage ../$g > $g
end
