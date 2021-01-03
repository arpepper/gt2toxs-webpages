# gt2toxs-webpages

Web pages, originally created for the author's geocities userid gt2toxs.  The tar file should end up as a file hierarchy which, if the top-level is removed, would work under apache (modulo .htaccess permissions of the server).  I resolved that top-level could go right under public_html, but alternatively in a sub-directory several levels below.  Therefore a top-level "public_html" is not part of the hierarchy here.

These are extremely dated fan pages for the Sony Gran Turismo series of games. Dating back to around 2004, they deal primarily with the original game, with a
smattering of information for the second game (GT2).  GT3 and GT4 are touched upon only in personal "game logs", and that is where the author's following of Gran Turismo ended--his wife never allowed him to purchase another Play Station after the PS2. that is, perhaps, not after the twenty-four hour races of GT4.

This is my second attempt with an identical repository name, because my first attempt included many gifs which were unnecessary and mildly inappropriate (as in insufficiently public-domain).  I completed deleted the first attempt, to try to make sure no artifacts of those remained.

To obtain the latest copy on branch "master"...

 curl -L -O https://github.com/arpepper/gt2toxs-webpages/archive/master.tar.gz

To clone the repository to later push back changes
(including "pull" requests?...

   git clone https://github.com/arpepper/gt2toxs-webpages.git

I still need to create something to "install" the information by modifying permissions (and possibly modification times) appropriately.  In practice, I tend to update my copies by untarring beside the copy and modifying copy content until

"diff -r --brief gt2toxs-webpages public_html" is appropriately quiet.

In fact, I distribute changes to cloned sites (cloud hosts and containers) by rsync'ing from the particular site I had been working on.


