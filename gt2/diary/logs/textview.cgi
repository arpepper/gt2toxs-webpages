#!/usr/bin/perl

{
$loaded_web ? return 1 : ($loaded_web = 1);
package web;
$| = 1;

# be secure
$ENV{'PATH'} = '';
$ENV{'SHELL'} = '/bin/sh';

# set pointers 
$tmpdir = '/tmp';

# programs
$sendmail = '/usr/lib/sendmail -t';
$hostcmd = '/.software/local/.admin/bins/bin/host';
$pwd = '/usr/bin/pwd';

# derived pointers
$homeurl = "$config'urlroot/";  # URL of home page
$me = "$config'scripturl/" . (($0 =~ /.*\//) ? $' : $0);

# set defaults
$timezone = 'EST';
$maxerrors = 25;
$filemode = 0644;

# global constants
$linebreak = '_' x 33 . '__ _ _ __' . '_' x 33;
@ewn = ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday');
@emn = ('January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December');
@fwn = ('dimanche', 'lundi', 'mardi', 'mercredi',
        'jeudi', 'vendredi', 'samedi');
@fmn = ('janvier', 'f&eacute;vrier', 'mars', 'avril', 'mai', 'juin', 'juillet',
        'ao&ucirc;t', 'septembre', 'octobre', 'novembre', 'd&eacute;cembre');
%mth = ('jan', 0, 'feb', 1, 'fev', 1, 'mar', 2, 'apr', 3, 'avr', 3,
        'may', 4, 'mai', 4, 'jun', 5, 'jul', 6, 'aug', 7, 'aou', 7,
        'sep', 8, 'oct', 9, 'nov', 10, 'dec', 11);

$doctype = '<!doctype html public "-//IETF//DTD HTML//EN//2.0">';
$homelink = "<a href=\"$config'urlroot\">$config'homeanchor</a>";
$footer = "<hr>$homelink";  # footer for HTML documents

# error handling

sub exit  # end HTML
    {
	local($title) = $_[0]; $title =~ s/<[^>]*>//g;
    #print "Content-Type: text/html\nPragma: no-cache\n\n<html><head><title>\n";
    #print "$title</title></head><body bgcolor=\"yellow\">\n";
    print "\n</body></html>\n";
    exit;
    }

sub checkerror  # exit on a system error code
    {
    return unless $!;
    local($whatever) = $_[0];
    &exit("Error: $!",
        "Sorry, an error occurred while trying to $whatever.\n<P>$lasterr");
    }

sub datetime  # produce a verbose date and time
    {
    local($s, $m, $h, $d, $l, $y, $w) = localtime($_[0] || time);
    $y += ($y < 90) ? 2000 : 1900;
    return sprintf("%02d:%02d:%02d $timezone " .
        "on $web'ewn[$w] $d $web'emn[$l] $y", $h, $m, $s) ;
    }

sub timestamp  # produce a terse date and time
    {
    local($s, $m, $h, $d, $n, $y, $w) = localtime; $y += ($y < 90) ? 2000:1900;
    return sprintf("%3s %2d %3s %4d, %02d:%02d:%02d",
        substr($ewn[$w], 0, 3), $d, substr($emn[$n], 0, 3), $y, $h, $m, $s);
    }

sub error  #  error message
    {
    print "Error!  $_[0]\n" if $web'SHELL;
    $lasterr = $_[0];
    eval "\$$errtarget .= \"\$_[0]\\n\"";
    return undef;
    }

$errtarget = "web'errmsg";

# url string encoding and decoding
sub urlencode  # escape spaces with '+', other specials with %xx
    {
    local($_) = $_[0];
    s/([\x00-\x1f!-*,:-?@\\\^`{-\xff])/'%'.unpack('H2', $1)/eg; s/ /\+/g; $_;
    # }  This comment lets vi % work...
    }

sub urldecode  # decode an escaped URL
    {
    local($_) = $_[0];
    s/\+/ /g; s/%([0-9a-fA-F][0-9a-fA-F])/pack('H2', $1)/eg; $_;
    }

# html string encoding and decoding
sub htmlencode  # escape special HTML characters (<, >, &, ")
    {
    local($_) = $_[0];
    s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g; s/"/&quot;/g; $_;
    }
 
sub htmldecode  # decode escaped HTML
    {
    local($_) = $_[0];
    s/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/&/g; $_;
    }

sub submit  # generate a URL containing all of the current form data
	{
	local($query, $var); local(*data) = eval("*_q");
	foreach $var (sort keys %data)
		{
		local(*ref) = $data{$var};
		$query .= &urlencode($var) . '=' . &urlencode($ref) . '?' if $ref;
		}
	return ($_[0] ? "$config'scripturl/$_[0]" : $me) . "?$query";
	}

sub hidden  # generate form elements containing all of the current form data
	{
	local($form, $var); local(*data) = eval("*_q");
	foreach $var (sort keys %data)
		{
		local(*ref) = $data{$var};
		$form .= "<input type=\"hidden\" name=\"$var\" value=\"$ref\">\n" 
			if $ref;
		}
	return $form;
	}

#
# stash - put URL submit data into appropriate variables for convenient access
#
# parse query data: place verbatim data in package "Q",
# decoded data in package "q", and html-encoded data in package "h"
#
# This only works for single-valued variables, ie not if "multiple"
#   was used in the select element of the form...
#
# This eval is sort of kludgey; you might as well use an explicit
#   hash.
#
sub stash
	{
	local($var,$value) = @_;
	local($qval) = &urldecode("$value");
	local($hval) = &htmlencode("$qval");
	
        &urldecode($var) =~ /\w+/;
	$var = $&; # make a safe variable name
	$var =~ s/^\d+//; # make a safe variable name
#print "\$Q'$var = \"\$value\";","\n";
	eval "\$Q'$var = ( defined(\$Q'$var) ? \"\$Q'$var,\$value\" : \"\$value\" );";
#print "\$q'$var = \"\$qval\";","\n";
	eval "\$q'$var = ( defined(\$q'$var) ? \"\$q'$var,\$qval\" : \"\$qval\");" ;
#print "\$h'$var = \"\$hval\";","\n";
	eval "\$h'$var = ( defined(\$h'$var) ? \"\$h'$var,\$hval\" : \"\$hval\");" ;
	}

$query="";
if ($ENV{'REQUEST_METHOD'} eq 'POST')
    {
    read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
    # save parsing till later, in case there is GET as well...
    }
elsif ($ENV{'REQUEST_METHOD'} eq 'GET')
    {
	# okay, but allow combined GET/POST queries
    }
elsif ($ENV{'REQUEST_METHOD'})
    {
    print "Content-Type: text/plain\n\nInvalid REQUEST_METHOD served.\n";
    exit;
    }

if (defined($ENV{'QUERY_STRING'}))
    {
    $query = $ENV{'QUERY_STRING'} . '&' . $query ;
    }

if ($query =~ /=/)
    {
    @fields = split(/[&\?]/, $query);
    foreach $f (@fields)
	{
	#
	# Problem: Submit will give the same var multiple times
	#   if you use the "multiple" option for a form select
	# stash arranges to change this into value,value,value...
	#
	next unless (($var, $value) = split('=', $f, 2)) == 2;
	&stash($var, $value);
	}
    }
else
    {
	&stash("word",$query);
    }

if ($q'base)
    {
    $q'base = &web'urldecode($q'base);
    $footer = "<HR><A HREF=\"$q'base\">To go back, please select this link.</A>";
    }

$back = &web'submit('form');  # generate the backlink to the request form

}   # end of package; should be a separate file

sub
mayview {
	my($name) = @_;

	$checklist = "./textlist.txt";

	if (open(FILE,"<$checklist")) {
		while (<FILE>) {
			$_ =~ s/\n//g;
			next if ($_ =~ /^#/);
			next if ($_ =~ /^\s*$/);
			if ( $_ eq $name ) {
				close(FILE);
				return 1;
			}
		}
	}
	close(FILE);
	return 0;
}

$grep = "";
$grep = (defined($q'grep)? $q'grep : $grep);

$filename = "";
$filename = (defined($q'filename)? $q'filename : $filename);
$filename =~ s:[^\-\/.a-zA-Z0-9_]::g;
$filename =~ s/[.][.]//g;
$filename =~ s:^/+::g;
$filename =~ s:^[.]+::g;
$filename =~ s:/[.]+:/:g;

$title = 'View File: ' . $filename ;

$public_html = "/u/arpepper/public_html";
$realfilename = "$public_html/$filename";
$realfilename = "$filename";

$headerfilename = "$filename";
$headerfilename =~ s:[^/]*$:: ;
$headerfilename = "${headerfilename}texthead.html";
$footerfilename = "$filename";
$footerfilename =~ s:[^/]*$:: ;
$footerfilename = "${footerfilename}textfoot.html";

#$realurl = "http://www.math.uwaterloo.ca/~arpepper/$filename";
$realurl = "$filename";
print "Content-Type: text/html\n\n<html>\n";

if (&mayview("$filename") && open(FILE,"<$headerfilename")){
	while (<FILE>) {
		print;     # should be HTML, no fixups...
	}
}
else {
	print "<head><title>$title</title></head><body bgcolor=\"yellow\">\n";
}

print "<h1> $title </h1>\n";

#print "<br>";
#print "$headerfilename";
#print "<br>";
#print "$footerfilename";
#print "<br>";

print "<form action=\"/cgi-bin/dummy_does_not_exist\">\n";
if (&mayview("$filename") ) {
	;
}
else {
	system("/bin/pwd");
	print "mayview failed\n";
	print "PERMISSION DENIED\n";
}
if ( $grep ne "" ) {
	print "<h3> Search for: $grep </h3>\n";
	print "<textarea rows=10 cols=82 readonly>\n";
	if (&mayview("$filename") && open(FILE,"<$realfilename")){
		while (<FILE>) {
			if ( $_ =~ /$grep/ ) {
				print;     # should do HTML fixup...
			}
		}
	}
	else {
	system("/bin/pwd");
		print "PERMISSION DENIED\n";
	}
}

print "</textarea><br>\n";
print "<h3> Entire contents of: $filename </h3>\n";
print "<textarea rows=24 cols=82 readonly>\n";
if (&mayview("$filename") && open(FILE,"<$realfilename")){
	while (<FILE>) {
		print;     # should do HTML fixup...
	}
	system("/bin/pwd");
}
else {
	system("/bin/pwd");
	print "PERMISSION DENIED $realfilename\n";
}

print "</textarea>\n";
print "</form>\n";


# We have a "base" directive in our header file which prevents relative...
print "<form method=POST action=\"/~arpepper/cgi-bin/textview?filename=$filename\">\n";
print "<p>Enter something to search for in this file:";
print "<input name=\"grep\" type=\"text\" length=30>\n";
print "<input type=\"submit\"></p>\n";
print "</form>\n";

print "<p>Click <a href=\"$realurl\">here</a> to get the actual text file.</p>\n";


if (&mayview("$filename") && open(FILE,"<$footerfilename")){
	while (<FILE>) {
		print;     # should be HTML, no fixups...
	}
}
else {
	&web'exit();
}



