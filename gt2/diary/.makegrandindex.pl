#!/xhbin/perl5 -w

#
# tranform - prepare given text to be included in html
#
sub
transform {
	local ($line) = @_;
	$line =~ s/&/&amp;/g;
	$line =~ s/</&lt;/g;
	if ( $line =~ /http:[\/][\/]/ ) {
		$line =~ s;http://[\w\-~/.]*;<a href="$&">$&</a>;g
	}
	$line =~ s,8-\),<img src="../bitmaps/happyfrog.gif" alt="8-)">,g;
	$line =~ s,8-\(,<img src="../bitmaps/sadfrog.gif" alt="8-(">,g;
	$line =~ s,\(-8,<img src="../bitmaps/happyfrog.gif" alt="(-8">,g;
	$line =~ s,\)-8,<img src="../bitmaps/sadfrog.gif" alt=")-8">,g;
	$line =~ s/\([Cc]\)/&copy;/g;

	$line;
}

if (!open(FILE,"<text/.titles.dat") ) {
	die "Cannot open title info file\n";
}

while (<FILE>) {
	$_ =~ s/\n//g;
	($fn, $title) = split(/:/, $_, 2);
	$titles{$fn} = $title;
}
close(FILE);

$date = `date`;

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

print "</td>","\n";
print "</table>","\n";

system "./.makediarynav.pl";

print "<a name=\"threads\"><hr></a>\n";

if (!open(FILE,"<text/.thrl.dat") ) {
	die "Cannot open thread info file\n";
}
		print << "_EOF_" ;
<H4>Last updated at $date</H4>
<table width="85%"><tr><td width="10%"></td><td>
<h3>Thread (or Topic) List</h3>
<p>
Here we present a list of "threads" linking entries
which deal with common subjects.
</p>
<p>
If you select a thread from here, you will be taken to a list
of all titles on that thread, so you can select any page.
</p>

<ul>
_EOF_

$thread = "";
while (<FILE>) {
	$_ =~ s/\n//g;
	$_ =~ s/:.*//g;
	$fn = $_;
	$fn =~ s/[.].*//g;
	if ($thread) {
		if ($_ !~ /^\S/) {
			$thread = "";
		}
	}
	elsif ($_ =~ /\S/) {
		$thread = $_;
		$anc = $thread;
		$anc =~ s/ /_/g;
		print << "_EOF_" ;
<li><a href="#$anc">$thread</a>
_EOF_
	}
}

print "</ul>\n</table><br><br>\n";

close(FILE);

if (!open(FILE,"<text/.thrl.dat") ) {
	die "Cannot open thread info file\n";
}

$thread = "";
while (<FILE>) {
	$_ =~ s/\n//g;
	$_ =~ s/:.*//g;
	$fn = $_;
	$fn =~ s/[.].*//g;
	if ($thread) {
		if ($_ !~ /^\S/) {
			$thread = "";
			print "</ul>\nBack to <a href=\"#threads\">Thread List</a></table><br><br>\n";
		}
		else {
			$line = $titles{$fn};
			($edate, $title) = split(" -- ",$line,2);
			printf("<li><a href=\"%s#%s\">%s</a> -- %s\n",
				$fn . ".html", $anc, $edate, $title);
		}
	}
	elsif ($_ =~ /\S/) {
		$thread = $_;
		$anc = $thread;
		$anc =~ s/ /_/g;
		print << "_EOF_" ;
<a name="$anc"><hr></a>
<table width="100%"><tr><td width="10%"></td><td>
<h4>$thread</h4>
<ul>
_EOF_
	}
}
if ($thread) {
	print "</ul>\n</table><br><br><hr>\n";
}
close(FILE);


print << "_EOF_" ;
<hr>

<table width="85%"><tr><td width="10%"></td><td>
<H4>Last updated at $date</H4>
<p>
As another alternative, you can use the <a href=\"search.html">search</a>
facility, (obtained from the Freeware source indicated therein).
</p>
</td></tr></table>


_EOF_

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

print "<hr>","\n";
print "<H4>Last updated at $date</H4>\n";

system "./.makediarynav.pl";

print "<br>","\n";
print "</font>\n";
print "<p>","\n";
print "Copyright &copy; 1999-2004, the author/owner of http://www.math.uwaterloo.ca/~arpepper\n";
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
