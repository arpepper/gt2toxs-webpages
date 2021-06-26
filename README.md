# gt2toxs-webpages

Web pages, originally created for the author's geocities userid gt2toxs.  The tar file should end up as a file hierarchy which, if the top-level is removed, would work under apache (modulo .htaccess permissions of the server).  I resolved that top-level could go right under public_html, but alternatively in a sub-directory several levels below.  Therefore a top-level "public_html" is not part of the hierarchy here.

After some thought I realize the most useful things here are an HTML CGI facility named "gears" and a general JavaScript toy database query "selana.html".

The CGI "gears" produces numeric tabular results for simplistically modelled automobile gear ratios.  Although based on the parameters as Gran Turismo provided them, it is not specific to the game, except perhaps for ignoring possible real-life considerations such as tire slippage or diameter change with inflation pressure and speed.  It is sort of a specialized equation solver.

"selana.html" is, perhaps yet-another, simple query interface for a single table of data (perhaps a join of other conceptual component tables).  The data can be almost arbitrary; for example I have used this for a personal address book.  "selana" comes from "SELect and ANAlyze"; but also it sounds vaguely like a female name.

For a while, also, the Gran Turismo 2 code translator for the Game Shark was used a little bit. I.e.
   gt2/translator
   gt2/geo/gt/translator

And recently I came to realize that in the directory where I keep game logs, I have specialized log interpreting programs.   Originally there was "garage" (for GT1), then "gt2garage","gt3garage" and "gt4garage".

Recently I have been adding lots of features (and options) to "gt4garage".  It currently handles GT3 game logs as well as GT4 logs, and eventually I would like to make it handle the older versions too.  In fact, it handles one log I created for the game "Alfa Romeo Racing Italiano", producing sort of a garage, although it is really more of an inventory, consisting not only of cars, but also the clothing items which are an important part of that game.  Handling of multiple games is done by using the "include" facility access files containing race definitions specific to the game in question.

Conceivably, someone else could make use of the "gt4garage" program, if they chose to prepare logs using the same syntax and semantics I do.

Other than that, these are extremely dated fan pages for the Sony Gran Turismo series of games, dating back to around 2004.  They deal primarily with the original game, with a smattering of information for the second game (GT2).  GT3 and GT4 are touched upon only in personal "game logs", and that is where the author's following of Gran Turismo ended--his wife never allowed him to purchase another Play Station after the PS2. that is, perhaps, not after the twenty-four hour races of GT4.

This is my second attempt with an identical repository name, because my first attempt included many gifs which were unnecessary and mildly inappropriate (as in insufficiently public-domain).  I completed deleted the first attempt, to try to make sure no artifacts of those remained.

To obtain the latest copy on branch "master"...

 curl -L -O https://github.com/arpepper/gt2toxs-webpages/archive/master.tar.gz

To clone the repository to later push back changes
(including "pull" requests?...

   git clone https://github.com/arpepper/gt2toxs-webpages.git

Or, to parallel updates via push

   export GIT_SSH_COMMAND='ssh -x -i &lt;path-to-private-key>'<br>
   git clone ssh://git@github.com/arpepper/gt2toxs-webpages.git

(In fact, "git push" will tend to just work if I have done the above)
(Of course pushes are not allowed for other users; I sort of doubt I will ever need to deal with someone doing a "pull" request, but if I do it will be a learning experience for me).

I still need to create something to "install" the information by modifying permissions (and possibly modification times) appropriately.  In practice, I tend to update my copies by untarring beside the copy and modifying copy content until

"diff -r --brief gt2toxs-webpages public_html" is appropriately quiet.

In fact, I distribute changes to cloned sites (cloud hosts and containers) by rsync'ing from the particular site I had been working on.


