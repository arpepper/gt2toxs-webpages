#!/bin/csh -f
cd /home/arpepper/public_html/gt2/diary/logs/test-gt1-garages
foreach g ( `cat gt1-gamelist.txt` )
	diff --brief ../saved-gt1-garages/$g $g
end
