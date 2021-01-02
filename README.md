# gt2toxs-webpages

Web pages, originally created for my geocities userid gt2toxs.  The tar file should end up as a file hierarchy which, if the top-level is removed, would work under apache (modulo .htaccess permissions of the server).  I resolved that top-level could go right under public_html, but alternatively in a sub-directory several levels below.  Therefore a top-level "public_html" is not part of the hierarchy here.

This is my second attempt with an identical repository name, because my first attempt included many gifs which were unnecessary and mildly inappropriate.  I completed deleted the first attempt, to try to make sure no artifacts of those remained.

To obtain the latest copy on branch "master"...
curl -L -O https://github.com/arpepper/gt2toxs-webpages/archive/master.tar.gz

To clone the repository to later push back changes...

   git clone https://github.com/arpepper/gt2toxs-webpages.git

I still need to create something to "install" the information by modifying permissions (and possibly modification times) appropriately.  In practice, I tend to update my copies by untarring beside the copy and modifying copy content until

"diff -r --brief gt2toxs-webpages public_html" is appropriately quiet.
