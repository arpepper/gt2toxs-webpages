#!/usr/bin/perl -w

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


sub
displaythreads {
	my($thr,$temp,$anc);

	#print "<a name=\"threads\"><h4>Threads:</h4></a>","\n";
	#print "<ul>","\n";
	foreach $thr (sort keys %threadstartlist) {
		$anc = $thr;
		$anc =~ s/ /_/g;
		#print "<li>";
		if (defined($threadstartlist{$thr}) &&
			$threadstartlist{$thr} ne "" ) {
			$temp = $threadstartlist{$thr};
			$temp =~ s/.txt$/.html/;
			print "<a href=\"${temp}#${anc}\">";
			print &transform("$thr"),"\n";
			print "</a>\n";
		}
		if (defined($threadendlist{$thr}) &&
			$threadendlist{$thr} ne "" ) {
			$temp = $threadendlist{$thr};
			$temp =~ s/.txt$/.html/;
			print "--&gt;&gt;";
			print "<a href=\"${temp}#${anc}\">";
			print "(End)";
			print "</a>\n";
		}
		#print "</li>","\n";
		print "<br>","\n";
	}
	#print "</ul>","\n";
}

if (!open(FILE,"<text/.thrl.dat") ) {
	die "Cannot open thread info file\n";
}

$thread = "";
$prevthread = "";
$thread = "";
while (<FILE>) {
	$_ =~ s/\n//g;
	$_ =~ s/:.*//g;
	if ($thread) {
		if (!defined($threadstartlist{$thread})
			|| $threadstartlist{$thread} eq "") {
			$threadstartlist{$thread} = $_;
			$prevthread = $_;
		}
		elsif ($_ =~ /^\s*$/ ) {
			$threadendlist{$thread} = $prevthread;
			$thread = "";
			$prevthread = "";
		}
		else {
			$prevthread = $_;
		}
	}
	elsif ($_ =~ /\S/) {
		$thread = $_;
		$prevthread = "";
	}
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

print "<hr>","\n";

print << "_EOF_" ;
<table width="85%"><tr><td width="10%"></td><td>
<H4>Last updated at $date</H4>
<p>
Here we present a list of "threads" linking entries
which deal with common subjects.
You can start a thread from here at either the beginning or the end, and then
move back and forth through it.
Many pages also present other threads you can traverse.
</p>
</td></tr></table>

<hr>

<table width="85%"><tr><td width="10%"></td><td>
_EOF_

&displaythreads;

print "</td></tr></table>","\n";

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
