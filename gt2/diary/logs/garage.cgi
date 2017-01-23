#!/usr/bin/perl
# modified by Adrian Pepper, but still a lot of the original code, Oct 1999

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
    #  } this comment is just to match {} for vi purposes...
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

if ($ENV{'REQUEST_METHOD'} eq 'POST')
    {
    read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
    @fields = split('&', $query);
    foreach $f (@fields)
        {
        ($var, $value) = split('=', $f, 2);
	&stash($var, $value);
        }
    }
elsif ($ENV{'REQUEST_METHOD'} eq 'GET')
    {
    $query = $ENV{'QUERY_STRING'} || $ARGV[0];
    if ($query =~ /=/)
        {
        @fields = split(/[&\?]/, $query);
        foreach $f (@fields)
            {
	#
	# Problem: Submit will give the same var multiple times
        #   if you use the "multiple" option for a form select
	#
            next unless (($var, $value) = split('=', $f, 2)) == 2;
	    &stash($var, $value);
            }
        }
    else
        {
	&stash("word",$query);
        }
    }
elsif ($ENV{'REQUEST_METHOD'})
    {
    print "Content-Type: text/plain\n\nInvalid REQUEST_METHOD served.\n";
    exit;
    }

if ($q'base)
    {
    $q'base = &web'urldecode($q'base);
    $footer = "<HR><A HREF=\"$q'base\">To go back, please select this link.</A>";
    }

$back = &web'submit('form');  # generate the backlink to the request form

}   # end of package; should be a separate file

$title = 'Gran Turismo Garage Contents';
print "Content-Type: text/html\nPragma: no-cache\n\n<html><head><title>\n";
print "$title</title></head><body bgcolor=\"yellow\">\n";


$fields = "";
$sortby = "";
$showflags = 0;

$garage = "blue";
$simday = "1168";
$showflags = ",garage,";

$garage = (defined($q'garage)? $q'garage : $garage);
$simday = (defined($q'simday)? $q'simday : $simday);
$showflags = (defined($q'showflags)? $q'showflags : $showflags);
$gcommand = "./garage";
if ( $garage =~ /^gt2-/ ) {
	$gcommand = "./gt2garage";
}
if ( $garage =~ /^gt3-/ ) {
	$gcommand = "./gt3garage";
}
if ( $garage =~ /^gt4-/ ) {
	$gcommand = "./gt4garage";
}

$qstring = "";
@qargs = ();
if ($showflags ne "") {
	push @qargs,"show=$showflags";
}
push @qargs,"$garage";
if ($simday ne "") {
	push @qargs,"$simday";
}

#
# following will need to be replaced by an execl to avoid interpretation
#   of strings...
#
#$output=`cd /u/arpepper/public_html/gt/diary/logs; $gcommand show=$showflags $garage $simday`;


#=================================================================
#  We claim the following is "safe graves"
#=================================================================
$pid = open(SELECTION,"-|");
unless (defined($pid)) {
	die "Could not fork";
}
if ($pid) {   # parent
	#$OldSep = $/;
	#undef($/);
	# This is impractical for large results
	#$output = <SELECTION>;
	#$/ = $OldSep;
}
else {   # child
	#$chdir "/u/arpepper/public_html/gt/diary/logs";
	close(STDERR);
	#dup2(STDOUT,STDERR);
	#print STDERR "And away we go...";
	exec "$gcommand", (@qargs);
	die "exec failed $!";
}
#=================================================================

$debug_output="";
#$q'debug = 1;
if (defined($q'debug)) {
	$query = "";
	$query = $web'query  if (defined($web'query));
	$query = &web'htmlencode($query);
	$debug_output = "";
	$debug_output .= <<EOF
<p>
<br>
$query<br>
<br>
</p>
EOF
}


#<base href="http://www.math.uwaterloo.ca/~arpepper/gt/diary/logs/">
print <<EOF  ;
<table width="100%" bgcolor="black">
<tr color="white">
<td>
<font color="white">
<h3><img src="../../../gifs/gtlogo.jpg" alt="Gran Turismo"> Garage Contents</h3>
</font>
</td>
</table>
<p>
To contact the author by
<a href="../email.html">email</a>.
</p>
$debug_output
EOF

print "<p>Contents of the <a href=\"textview?filename=gt/diary/logs/$garage\">$garage</a> game garage, \n";
if ($simday =~  /^\d+$/ && $simday > 0) {
	print "after simulation day $simday was completed"
}
elsif ($simday ne "") {
	print "after date $simday was matched."
}
else {
	print "at the end of all the days logged";
}
print "</p>\n";
#print "<table border bgcolor=\"white\">\n";
$count = 0;
while (<SELECTION>) {
	#print $_;
	
	$output = $_;
	if ($output =~ /^\s*\d+:/ ) {
		$output =~ s,\s*(\d+):(\S+)(.*),<tr><td>$1</td><td>$2</td><td>$3</td></tr>,;
	}
	else {
		$output =~ s:\s*(\S+)(.*):<tr><td> $simday </td><td>$1</td><td>$2</td></tr>:;
	}
	if ($count == 0) {
		print "<table border bgcolor=\"white\">\n";
	}
	print $output;
	++$count;
}
if ($count == 0) {
	print <<EOF  ;
	<table width="50%" border bgcolor="white">
	<tr><td align="left" bgcolor="black" width="100%">
	<font color="cyan">
<pre>

     N/A









</pre>
	</td></tr>
EOF
}
close(SELECTION);
print "</table>\n";


$selname = "";
$valname = "";
@farray = split(/,/,$fields);
$sortby =~ s/-//g;   # use reverse switch instead  8-)
@sarray = split(/,/,$sortby);
sub
fillin {
	local($line) = @_;
	local($val);

	if ($line =~ /^<select name="([^"]*)/ ) {
		$selname = $1;
		$valname = "";
	}
	elsif ($line =~ /^<\/select/) {
		shift @types if @types && ($selname eq "t");
		shift @queries if @queries && ($selname eq "q");
		shift @nots if @nots && ($selname eq "n");
		shift @ops if @ops && ($selname eq "op");
		$selname = "";
	}
	elsif ($line =~ /^<input .* name="([^"]*)/ ) {
		$selname = "";
		$valname = $1;
		if ($valname eq "simday") {
			if (defined($simday)) {
				$simday =~ s/"//g;
				$line =~ s/(value=")[^"]*/$1$simday/;
			}
		}
	}
	elsif ($line =~ /^\s*<option value="([^"]*)/ ) {
		$val = $1;
		if ($selname eq "garage") {
			if ($val eq $garage) {
				$line =~ s/>/ selected>/;
			}
		}
	}


	return $line;
}

if (open(SELECTION,"< ./garage.html")) {
	print "<hr>\n";
	$inform = 0;
	while (<SELECTION>) {
		if ($_ =~ /^<form/) {
			$inform = 1;
		}
		if ($inform) {
			print &fillin($_);
		}
		last if ($_ =~ /^<\/form/);
	}
	close(SELECTION);
}


&web'exit();
