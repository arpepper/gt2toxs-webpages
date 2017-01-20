#!/xhbin/perl5 -w

#
# Usage:
#   ./makediarynav.pl [omit ...]
#

@skip = @ARGV;

sub
show {
	local($s) = @_;
	local($x);

	foreach $x (@skip) {
		return 0 if ($s eq $x);
	}
	return 1;
}

#$title = "My Gran Turismo Diaries";
#$date = `date`;

$first = `ls [12][0-9][0-9][0-9]-*.html | head -1`;
$first =~ s/\n//g;
$last = `ls [12][0-9][0-9][0-9]-*.html | tail -1`;
$last =~ s/\n//g;

print "<font size=-1 color=\"blue\">\n";
print "<p>\n";
print "[<a href=\"$first\">First Entry</a>&nbsp;]\n" if show("first");
print "[<a href=\"index.html\">Index</a>&nbsp;]\n" if show("index");
print "[<a href=\"fullindex.html\">Full Index</a>&nbsp;]\n" if show("fullindex");
print "[<a href=\"search.html\">Search</a>&nbsp;]\n" if show("search");
print "[<a href=\"../\">Gran Turismo Pages</a>&nbsp;]\n" if show("pages");
print "[<a href=\"../logs/\">game logs</a>&nbsp;]\n" if show("logs");
print "[<a href=\"../email.html\">email</a>&nbsp;]\n" if show("email");
print "[<a href=\"$last\">Most Recent Entry</a>&nbsp;]\n" if show("last");
print "</p>\n";
print "</font>\n";

