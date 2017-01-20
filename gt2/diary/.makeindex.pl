#!/xhbin/perl5 -w

$title = "My Gran Turismo Diaries";

print "<html>\n<head>\n";
print "<meta name=\"robots\" content=\"nofollow\">\n\n";
print "<title>\n";
print $title,"</title>","\n";
print "</head>\n\n";
print "<body background=\"../../bitmaps/yblinedpaper.gif\" link=\"red\" vlink=\"brown\" alink=\"red\">","\n";
print "<table width=\"100%\" bgcolor=\"black\">"."\n";
print "<tr color=\"white\">","\n";
print "<td>","\n";
print "<font color=\"white\">","\n";
print "<h3>My <img src=\"../../gifs/gtlogo.jpg\" alt=\"Gran Turismo\"> Diaries</h3>","\n";
print "</font>","\n";
print "<font color=\"white\">","\n";
print "<h4>A Lurid Tale of Obsession, Depravity, Wits and Attempted Wit</h4>","\n";
print "</font>","\n";

#print "<font color=\"white\">","\n";
#print "<h3>",$title,"</h3>\n";
#print "</font>","\n";
#if ($subtitle ne "" ) {
#	print "<font color=\"white\">","\n";
#	print "<h4>",$subtitle,"</h4>\n";
#	print "</font>","\n";
#}
#print "<font size=-1 color=\"white\">\n";
#print "<p>","\n";
#if ($prevpage ne "") {
#	print "[<a href=$prevpage>","Previous Entry","</a>","&nbsp;","]\n";
#}
#if ($index ne "") {
#	print "[<a href=$index>","Index","</a>","&nbsp;","]\n";
#}
#if ($nextpage ne "") {
#	print "[<a href=$nextpage>","Next Entry","</a>","&nbsp;","]\n";
#}
#print "</p>","\n";
#print "</font>\n";
print "</td>","\n";
print "</table>","\n";

#print $font_start,"\n";
#print "<h3>",$title,"</h3>\n";
#if ($subtitle ne "" ) {
#	print "<h4>",$subtitle,"</h4>\n";
#}
#print $font_end,"\n";
#print "<table width=\"85%\">","\n";
#print "<tr>","\n";
#print "<td width=\"10%\"></td>","\n";
#print "<td>","\n";

$last = `ls [12][0-9][0-9][0-9]-*.html | tail -1`;
$last =~ s/\n//g;
$first = `ls [12][0-9][0-9][0-9]-*.html | head -1`;
$first =~ s/\n//g;
$date = `date`;

system "./.makediarynav.pl";

print "</p>\n";
print "</font>\n";

print "<hr>","\n";

print << "_EOF_" ;
<H4>Last updated at $date</H4>
<table width="85%"><tr><td width="5%"></td><td>
<p>
These pages were created as daily entries, and the full list is listed here.
To try and find an entry related to a topic ("thread"), try the following
<a href="fullindex.html">grand thread index</a>.
</p>
<p>
Or you can start at the
<a href="$first">first</a>
or, more reasonably, the
<a href="$last">most recent</a> entry, and go from there.
</p>
<p>
As another alternative, you can use the new <a href="search.html">search</a>
facility, (obtained from the Freeware source indicated therein).
</p>
<p>
If you find this overwhelming you might want to look at
the  simple <a href="threadindex.html">list of "threads"</a>
which contains links to the first and last entries dealing with
various subjects.
</p>
<p><font size="-2"><a name="top" href="#about">More about these pages</a></font>
</p>
</td></tr></table>
<hr>
_EOF_



print "<ul>","\n";

sub
flushlast {
	if ( $h3 ) {
		print "<li>","\n";
		if ( $me ne "" ) {
			print "<a href=\"$me\">","\n";
		}
		$h3 =~ s/\n//mg;
		$h3 =~ s/<[^>]*>//g;
		print $h3,"\n";
		if ( $me ne "" ) {
			print "</a>","\n";
		}
		if ( $h4 ) {
			$h4 =~ s/\n//mg;
			$h4 =~ s/<[^>]*>//g;
			print " -- ",$h4,"\n";
		}
		print "</li>";
	}
	$h3 = "";
	$h4 = "";
	$me = "";

}

$me = "";

while ( <> ) {
	if ( $me eq "" ) {
		$me = $ARGV;
		$myplace = $me;
		if ($myplace =~ /^\// ) {
			$myplace =~ s:[^/]*$:: ;
			$me =~ s:^.*/::;
		}
		else {
			$myplace = ".";
		}
#print $me,"\n",$myplace,"\n";
	}
	if ( $_ =~ /^<\/html>/ ) {
		&flushlast;
	}
	if ( $_ =~ /^<h3>/ ) {
		if ( $_ !~ /^<h3>My /) {
			$h3 = $_;
		}
	}
	if ( $_ =~ /^<\/h3>/ ) {
		if ( $h3 ) {
			$h3 .= $_;
		}
	}
	if ( $_ =~ /^<h4>/ ) {
		if ( $_ !~ /^<h4>A Lurid /) {
			$h4 = $_;
		}
	}
	if ( $_ =~ /^<\/h4>/ ) {
		if ( $h4 ) {
			$h4 .= $_;
		}
	}
}

&flushlast;

print "</ul>","\n";
print <<"_EOF_" ;
<hr>
<table width="85%"><tr><td width="5%"></td><td>

<p>
<a name="about" href="#top">These</a> pages began as an experiment to help
me explore some ideas regarding
using HTML, and, specifically, converting naturalish text documents into
reasonable HTMl, and linking those pages together in various appropriate
ways.  Quite clearly, the rate at which I am learning anything by creating
these pages has diminished a lot.  Or, in other words, they have probably
got out-of-hand.
</p>
<p>
Consequently these pages may soon disappear with little or no notice.
(Other than this).  Updates have become very sporadic recently.  That
is not necessarily a totally bad thing.  <img src="../../bitmaps/happyfrog.gif" alt="8-)">
</p>
<p>
I have actually managed to go to the
effort of having these pages hosted semi-professionally, but that has
resulted in a breakage of some links to facilities now not available.
</p>
</td></tr></table>
_EOF_


print "<hr>","\n";

print "<H4>Last updated at $date</H4>\n";


system "./.makediarynav.pl";

print "<font size=-2>\n";
print "<p>","\n";
#if ($prevpage ne "") {
#	print "[<a href=$prevpage>","Previous Entry","</a>","&nbsp;","]\n";
#}
#if ($index ne "") {
#	print "[<a href=$index>","Index","</a>","&nbsp;","]\n";
#}
#if ($nextpage ne "") {
#	print "[<a href=$nextpage>","Next Entry","</a>","&nbsp;","]\n";
#}
print "</p>","\n";
print "<br>","\n";
print "</font>\n";
print "<p>","\n";
print "Copyright &copy; 1999-2004 the author/owner of http://www.math.uwaterloo.ca/~arpepper\n";
print "</p>","\n";
print "<font size=-2>\n";
print "<p>","\n";
print "<a href=email.html>email</a>","\n";
print "</p>","\n";
print "<p>","\n";
print "<a href=disclaimer.html>Disclaimers</a>","\n";
print "</p>","\n";
print "</font>\n";

print "</body>","\n","</html>","\n";
