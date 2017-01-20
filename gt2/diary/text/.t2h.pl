#!/xhbin/perl5

$codes = 0;   # when set to one, we allow internal codes.
#
# tranform - prepare given text to be included in html
#
sub
transform {
	local ($line,$type) = @_;
	local ($html);

	$html = "";
	if ( $line =~ /<html>/ ) {
		$line =~ s:(<html>.*</html>):#####HTML1#####:s ;
		$html = $1;
		$html =~ s/<html>//g;
		$html =~ s:</html>::g
	}
	if ($codes == 0) {
		$line =~ s/&/&amp;/g;
		$line =~ s/</&lt;/g;
	}
	if ( $line =~ /http:[\/][\/]/ ) {
		$line =~ s;http://[\w\-~/.]*;<a href="$&">$&</a>;g
	}
	$line =~ s,8-\),<img src="../../bitmaps/happyfrog.gif" width="30" height="18" border="0" alt="8-)">,g;
	$line =~ s,8-\(,<img src="../../bitmaps/sadfrog.gif" width="30" height="18" border="0" alt="8-(">,g;
	$line =~ s,\(-8,<img src="../../bitmaps/happyfrog.gif" width="30" height="18" border="0" alt="(-8">,g;
	$line =~ s,\)-8,<img src="../../bitmaps/sadfrog.gif" width="30" height="18" border="0" alt=")-8">,g;
	$line =~ s/\([Cc]\)/&copy;/g;
	if ( $html ne "" ) {
		$line =~ s:#####HTML1#####:${html}: ;
	}

	$line;
}

#
# process - add appropriate formatting information for the transformed text
#
sub
process {
	local ($hunk,$type) = @_;
	local ($indent,$percent,$filler) = 0;

	if ($type eq "prog") {
		$hunk = "<pre>\n" . $hunk . "</pre>\n";
	}
	if ($type eq "list" ) {
		if ( $hunk =~ /^\s+-/gm ) {
			$hunk =~ s/^\s+-/<li>/gm;
			$hunk =~ s/\n\s+/ /g;
			$hunk =~ s,$,</li>,gm;
			return $starter{$type} . "<ul>" . $hunk . "</ul>" . $ender{$type};
		}
		else {
			# problem, doing this renders anchors unrecognizable
			$hunk =~ s/ /&nbsp;/gm;
			$hunk =~ s,$,<br>,gm;
			while ( $hunk =~ /<[^>]*&nbsp;/ ) {
				$hunk =~ s/(<[^>]*)&nbsp;/\1 /;
			}
			return $starter{$type} . $hunk . $ender{$type};
		}
	}
	if ($type eq "prog" ) {
		$indent = &pcount("^ ",$hunk);
		$percent = "10%";
		$filler = "";
		if ($indent > 0) {
			$percent = "15%";
			$filler = "&nbsp;&nbsp;";
		}
		# ick.  following is logically $para_start, modified...
		return &indent_start($percent,$filler) . "<font face=\"Courier\">" . "\n" . $hunk . $ender{$type};
	}
	if ($type eq "para" ) {
		$indent = &pcount("^ ",$hunk);
		$percent = "10%";
		$filler = "";
		if ($indent > 0) {
			$percent = "15%";
			$filler = "&nbsp;&nbsp;";
		}
		# ick.  following is logically $para_start, modified...
		return &indent_start($percent,$filler) . $font_start . "<p>\n" . $hunk . $ender{$type};
	}
	if ($type eq "table" ) {
		# problem, doing this renders anchors unrecognizable
		$hunk =~ s/ /&nbsp;/gm;
		$hunk =~ s,$,<br>,gm;
		while ( $hunk =~ /<[^>]*&nbsp;/ ) {
			$hunk =~ s/(<[^>]*)&nbsp;/\1 /;
		}
		# detailed table analysis here, or earlier?
		$hunk =~ s,^,<tr><td>&nbsp;&nbsp;</td><td><font face="courier">,gm;
		$hunk =~ s,$,</font></td></tr>,gm;
		# now remove the first one we added...
		$hunk =~ s,^<tr><td>&nbsp;&nbsp;</td><td>,,;
		return "<font face=\"Courier\">" . &indent_start("15%","&nbsp;&nbsp;") . $hunk . $indent_end . "</font>";
	}
	return $hunk;
}

sub
indent_start {
	local ($amount,$fill) = @_;
	
	return "<table width=\"85%\"><tr><td width=\"$amount\">$fill</td>\n<td>";
}

sub
pcount {
	local ($pattern,$string) = @_;
	local @junk;

	@junk = split(/$pattern/gm,$string);
	return $#junk;
}
	

sub
identify {
	local ($hunk,$hint) = @_;
	local ($thunk,$indent,$nindent);
	local @lines;

	if ($hint eq "literal") {
		return $hint;
	}
	if ($hint =~ /^blank/) {
		return $hint;
	}
	if ($hint =~ /^prog/) {
		return $hint;
	}
	# $hint must be "list" or "para"; not sure it's very relevant
	$thunk = $hunk;
	$thunk =~ s/^\s+//gm;
	$mspace_c = &pcount("  ",$thunk);
	$sentence_c = &pcount("[.?:;!)]  ",$thunk);
	$sentence_c += 2*&pcount("[8.]-[(]",$thunk);
	$sentence_c += 2*&pcount("[(]-[8.]",$thunk);
	$sentence_c += &pcount("[8.]-[)]",$thunk);
	if ($mspace_c > $sentence_c + 1) {
		return "table";
	}
	$point_c = &pcount("^-",$thunk);
	if ($point_c > 1) {
		return "list";
	}
	$line_c = &pcount("\n",$thunk);
	$space_c = &pcount(" ",$thunk);
	if ( $space_c < $line_c * 4 ) {
		return "table";
	}
	$nindent = 0;
	$total = 0;
	$previndent = -1;
	@lines = split(/\n/, $hunk);
	for ($i = 0; $i <= $#lines; ++$i ) {
		$total += length($lines[$i]);
		$prefix = $lines[$i];
		$prefix =~ s/\S.*//;
	# pcount/split does not work how we want with blanks? null fields?
	#	$indent = &pcount(" ",$prefix);
		$indent = length($prefix);     #  Duh
		if ( $previndent != $indent) {
			++$nindent;
		}
		$previndent = $indent;
	}
	if ($nindent > 1) {
		return "list";
	}
	if ( $#lines > 1 && ( $total / ($#lines + 1) ) < 40 ) {
		return "list";
	}
	# it may be indented, but it does not look like a list or table
	# so assume it is a paragraph
	return "para";
}

sub
display {
	local ($hunk,$hint) = @_;
	local $type;

	if ($hint eq "literal") {
		print $hunk;
		return;
	}
	if ($hunk eq "" || $hunk eq "\n") {
		return;
	}
	$type = &identify($hunk,$hint);
	$hunk = &transform($hunk,$type);
	$hunk = &process($hunk,$type);
	print $hunk;


}

sub
displaythreads {
	local($thr,$anchor,$noanchor);
	#return if ($nthreads <= 0);


	#print "<a name=\"threads\"><h4>Threads:</h4></a>","\n";
	#print "<ul>","\n";
#print "***nthreads: $nthreads<br>\n";
#foreach $thr (sort keys %threadlist) {
#$thrval = $threadlist{$thr};
#print "***thread: $thr | $thrval<br>\n";
#}
	foreach $thr (sort keys %threadlist) {
#warn "thread $thr\n";
#warn "prevthreadlist{$thr} ${prevthreadlist{$thr}}\n";
#warn "nextthreadlist{$thr} ${nextthreadlist{$thr}}\n";
		#print "<li>";
		$anchor = $thr;
		$anchor =~ s/ /_/g;
		$noanchor = defined($dropped_threads{$thr}) ||
			$suffixlist{$thr} ne "";
		if (defined($prevthreadlist{$thr}) &&
			$prevthreadlist{$thr} ne "" ) {
			$temp = $prevthreadlist{$thr};
			$temp =~ s/.txt$/.html/;
			print "<a href=\"${temp}#${anchor}\">";
			print "&lt;&lt;--";
			print "</a>\n";
		}
		else {
			print "||--";
		}
		if (!$noanchor) {
			print "<a name=\"$anchor\">";
		}
		else {
			print "<a href=\"#$anchor\">";

		}
		print &transform("$thr"),"\n";
		if (!$noanchor) {
			print "</a>";
			$dropped_threads{$thr} = $thr;
		}
		else {
			print "</a>";
		}
		if (defined($nextthreadlist{$thr}) &&
			$nextthreadlist{$thr} ne "" ) {
			$temp = $nextthreadlist{$thr};
			$temp =~ s/.txt$/.html/;
			print "<a href=\"${temp}#${anchor}\">";
			print "--&gt;&gt;";
			print "</a>\n";
		}
		else {
			print "--||";
		}
		#print "</li>","\n";
		print "<br>","\n";
	}
	#print "</ul>","\n";
}


$title = <>;   # must read to force ARGV to be right?

#
$me = $ARGV;
$myplace = $me;
if ($myplace =~ /\// ) {
	$myplace =~ s:[^/]*$:: ;
	$me =~ s:^.*/::;
}
else {
	$myplace = ".";
}
#print $me,"\n",$myplace,"\n";

$names = `cd $myplace; ls [12][90][0-9][0-9]-*-*.txt`;
@namelist = split(/\n/,$names);
$prevpage = "";
$nextpage = "";
$index = "index.html";

findme:
for ( $i = 0; $i <= $#namelist; ++$i) {
#print $namelist[$i],"\n";
	if ($namelist[$i] eq $me) {
		last findme;
	}
}
if ($i > 0) {
	$prevpage = $namelist[$i-1];
	$prevpage =~ s/.txt$/.html/;
}
if ($i <= $#namelist) {
	$nextpage = $namelist[$i+1];
	$nextpage =~ s/.txt$/.html/;
}
#print $me,"\n",$prevpage,"\n",$nextpage,"\n";

#
# Interpret the "thread information" stored in the file .thrl.dat
#   - pick out the threads we belong to
#
$nthreads = 0;
$thread = "";
$prevthread = "";
#
%prevthreadlist = ();
%threadlist = ();
%suffixlist = ();
%nextthreadlist = ();
if (open(FILE,"<.thrl.dat")) {
	$thread = "";
	while (<FILE>) {
		$_ =~ s/\n//g;
		$line = $_;
		$suffix = "";
		$line =~ s/:(.*)//g;
		if (defined($1)) {
			$suffix = $1;
		}
		if ($thread ne "") {
			if ($line eq $me) {
				++$nthreads;
				$prevthreadlist{$thread} = $prevthread;
				$threadlist{$thread} = $me;
				$suffixlist{$thread} = $suffix;
				$nextthreadlist{$thread} = "";
			}
			elsif ($line =~ /^\s*$/ ) {
				$thread = "";
				$prevthread = "";
			}
			elsif ( defined($threadlist{$thread}) &&
					$threadlist{$thread} eq $me &&
					$nextthreadlist{$thread} eq "" ) {
				$nextthreadlist{$thread} = $line;
			}
			else {
				$prevthread = $line;
			}
		}
		elsif ($line =~ /\S/) {
			$thread = $line;
			$prevthread = "";
		}
	}
	close(FILE);
}

#
# dropanchor
#   - attempt to create a forward/backward annotated thread reference
#
sub
dropanchor {
	local($threadname) = @_;
	local($anchorname,$noanchor,$temp);

	return if ($threadname eq "");
	$noanchor = defined($dropped_threads{$threadname});
	$dropped_threads{$threadname} = $threadname;
	$anchorname = $threadname;
	$anchorname =~ s/ /_/g;
	print "<font color=red>\n";
	if (defined($prevthreadlist{$threadname}) &&
		$prevthreadlist{$threadname} ne "" ) {
		$temp = $prevthreadlist{$threadname};
		$temp =~ s/.txt$/.html/;
		print "<a href=\"${temp}#${anchorname}\">";
		print "&lt;&lt;--";
		print "</a>\n";
	}
	else {
		print "||--";
	}
	if (!$noanchor) {
		print "<a name=\"$anchorname\">";
	}
	print &transform("$threadname");
	if (!$noanchor) {
		print "</a>";
	}
	if (defined($nextthreadlist{$threadname}) &&
		$nextthreadlist{$threadname} ne "" ) {
		$temp = $nextthreadlist{$threadname};
		$temp =~ s/.txt$/.html/;
		print "<a href=\"${temp}#${anchorname}\">";
		print "--&gt;&gt;";
		print "</a>\n";
	}
	else {
		print "--||";
	}
	print "</font><br>\n";

	
}

#warn "nthreads=$nthreads\n";

$font_start = "<font face=\"Comic Sans MS\">";
$font_end = "</font>";
$state = "unknown";
$newstate = "unknown";
$literal = 0;
$indented_literal = 0;
$inthreads = 0;
$indent_end = "</td></tr></table>\n";
$starter{"para"} = &indent_start("10%") . $font_start . "<p>\n";
$ender{"para"} = "</p>" . $font_end . $indent_end;
$starter{"list"} = &indent_start("10%") . "\n";
$ender{"list"} = $indent_end;
$ender{"prog"} = $font_end . $indent_end;
$starter{"blank1"} = "";
$ender{"blank1"} = "";
$starter{"blank2"} = "<br>\n";
$ender{"blank2"} = "";
$ender{"unknown"} = "";

while (($subtitle = <>) =~ /^[\s]*$/ ) {
	;
}

$chunk = <>;
if ( $chunk !~ /^[\s]*$/ ) {
	$chunk = $subtitle . $chunk;
	$subtitle = "";
	$state = "para";   # &lineparse($chunk);
}


print "<html>\n<head>\n";
print "<meta name=\"robots\" content=\"noindex,nofollow\">\n\n";
print "<title>\n";
print $title," -- ",$subtitle,"</title>","\n";
print "</head>\n\n";
print "<body background=\"../../bitmaps/yblinedpaper.gif\" link=\"red\" vlink=\"brown\" alink=\"red\">","\n";
print "<table width=\"100%\" bgcolor=\"black\">"."\n";
print "<tr color=\"white\">","\n";
print "<td>","\n";
print "<font color=\"white\">","\n";
print "<h3>My <img src=\"../../gifs/gtlogo.jpg\" height=\"121\" width=\"263\" border=\"0\" alt=\"Gran Turismo\"> Diaries</h3>","\n";
print "</font>","\n";
print "<font color=\"white\">","\n";
print "<h4>A Lurid Tale of Obsession, Depravity, Wits and Attempted Wit</h4>","\n";
print "</font>","\n";

print "<font color=\"white\">","\n";
print "<h3>",$title,"</h3>\n";
print "</font>","\n";
if ($subtitle ne "" ) {
	print "<font color=\"white\">","\n";
	print "<h4>",$subtitle,"</h4>\n";
	print "</font>","\n";
}
print "</td>","\n";
print "</table>","\n";
print "<font size=-1 color=\"blue\">\n";
print "<p>","\n";
if ($prevpage ne "") {
	print "[<a href=\"$prevpage\">","Previous Entry","</a>","&nbsp;","]\n";
}
if ($index ne "") {
	print "[<a href=$index>","Index","</a>","&nbsp;","]\n";
}
print "[<a href=\"search.html\">","Search","</a>","&nbsp;","]\n";
print "[<a href=\"../logs/\">","game logs","</a>","&nbsp;","]\n";
if ($nextpage ne "") {
	print "[<a href=\"$nextpage\">","Next Entry","</a>","&nbsp;","]\n";
}
print "[<a href=email.html>email</a>]","\n";
print "[<a href=disclaimer.html>Disclaimers</a>]","\n";
print "</p>","\n";
if ($nthreads > 0) {
	&displaythreads;
	#print "<p>","\n";
	#print "[<a href=#threads>","Threads","</a>","&nbsp;","]\n";
	#print "</p>","\n";
}
print "</font>\n";
print "<font size=-1>","\n";
print "<p>","\n";
print "Copyright &copy; 1999-2004, the author/owner of the following ==>\n";
print "<a href=\"../..\">page</a> &lt;==.";
print "</p>","\n";
print "</font>","\n";
print "<hr>","\n";
print $font_start,"\n";
print "<h3>",$title,"</h3>\n";
if ($subtitle ne "" ) {
	print "<h4>",$subtitle,"</h4>\n";
}
print $font_end,"\n";
#print "<table width=\"85%\">","\n";
#print "<tr>","\n";
#print "<td width=\"10%\"></td>","\n";
#print "<td>","\n";

mainloop:
while ( <> ) {
	# would be tempting to slurp initially.
	if ( $literal ) {
		if ( $_ =~ /^<\/HTML>$/ ) {
			$literal = 0;
			$chunk = "";
			if ( $indented_literal ) {
				print $indent_end;
				$indented_literal = 0;
			}
			$newstate = "unknown";
			$state = "unknown";
		}
		else {
			print $_;
		}
	}
	elsif ( $inthreads ) {
		if ( $_ =~ /^\s*$/ ) {
			$inthreads = 0;
			$chunk = "";
			$newstate = "unknown";
			$state = "unknown";
		}
	}
	elsif ( $_ =~ /^<HTML>$/ ) {
		&display($chunk,$state);
		$chunk = "";
		$literal = 1;
	}
	elsif ( $_ =~ /^<HTML +INDENT>$/ ) {
		&display($chunk,$state);
		# later we should maybe accept a value for the indent
		print &indent_start("10%","");
		$chunk = "";
		$literal = 1;
		$indented_literal = 1;
	}
	elsif ( $_ =~ /^<CODES>$/ ) {
		&display($chunk,$state);
		$chunk = "";
		$codes = 1;
	}
	elsif ( $_ =~ /^<\/CODES>$/ ) {
		&display($chunk,$state);
		$chunk = "";
		$codes = 0;
	}
	elsif ( $_ =~ /^Threads{0,1}:/ ) {
		&display($chunk,$state);
		$specthread = $_;
		$specthread =~ s/\n//g;
		$specthread =~ s/^[^:]*:\s*//;
		$specthread =~ s/\s*$//;
		&dropanchor($specthread);
		$chunk = "";
		if ($specthread eq "") {
			$inthreads = 1;
		}
		else {
			$newstate = "unknown";
			$state = "unknown";
		}
	}
	elsif ( $_ =~ /^=================*$/ ) {
		last mainloop;
	}
	elsif ( $newstate eq "prog" ) {
		$chunk .= $_;
		if ( $_ =~ /^---------*$/ ) {
			# just hope we never need such a line in a program...
			&display($chunk,$state);
			$chunk = "";
			$newstate = "unknown";
			$state = "unknown";
		}
	}
	else {
		# what you really want here is a proper grammar and stack...
		if ( $state ne "blank1" && $_ =~ /^\s*$/ ) {
			$newstate = "blank1"
		}
		elsif ( $_ =~ /^\s*$/ ) {
			$newstate = "blank2"
		}
		elsif ( $_ =~ /^\s*\#\!/ ) {
			$newstate = "prog"
		}
		elsif ( $_ =~ /^---------*$/ ) {
			$newstate = "prog"
		}
		elsif ( $_ =~ /^\S/ ) {
			$newstate = "para"
		}
		elsif ( $_ =~ /^\s/ ) {
			$newstate = "list";
		}
		if ( $newstate ne $state ) {
			&display($chunk,$state);
			$chunk = "";
		}
		if ( length($_) > 60 && $_ !~ /\s/ ) {
			&display($chunk,$state);
			$chunk = "";
			$newstate = "unknown";
		}
		
		$chunk .= $_;

		if ( $state eq $newstate && $newstate eq "para" ) {
			if ( length($_) < 60 ) {
				if ( $_ =~ /[.]$/ ) {
					&display($chunk,$state);
					$chunk = "";
				}
			}
		}
		$state = $newstate;
	}
}
&display($chunk,$state);
$chunk = "";

#print "</td>","\n";
#print "</table>","\n";

if ($nthreads > 0) {
	print "<hr>","\n";
	print "<font size=-1 color=\"blue\">\n";
	&displaythreads;
	print "</font>\n";
}

print "<hr>","\n";

print "<font size=-1 color=\"blue\">\n";
print "<p>","\n";
if ($prevpage ne "") {
	print "[<a href=\"$prevpage\">","Previous Entry","</a>","&nbsp;","]\n";
}
if ($index ne "") {
	print "[<a href=$index>","Index","</a>","&nbsp;","]\n";
}
print "[<a href=\"search.html\">","Search","</a>","&nbsp;","]\n";
print "[<a href=\"../logs/\">","game logs","</a>","&nbsp;","]\n";
if ($nextpage ne "") {
	print "[<a href=\"$nextpage\">","Next Entry","</a>","&nbsp;","]\n";
}
print "[<a href=email.html>email</a>]","\n";
print "[<a href=disclaimer.html>Disclaimers</a>]","\n";
print "</p>","\n";
print "<br>","\n";
print "</font>\n";
print "<p>","\n";
print "Copyright &copy; 1999-2004 the author/owner of the following ==>\n";
print "<a href=\"../..\">page</a> &lt;==.";
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
