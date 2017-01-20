#!/usr/bin/perl

# WWW Remote File Manager (Main Library)

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

sub
cached_demo {
	my($qs) = @_;
	my($cached,$hqs,$hcached);
	my(@queries,$query,$resfile);

	$hqs = &web'htmlencode($qs);
#print "qs=|$hqs|\n";
	@queries = split(/ /,`/bin/echo ./demo/query*`);
	foreach $query (@queries) {
		$cached = `/bin/cat $query`;
		$cached =~ s/\n$//m;
		$hcached = &web'htmlencode($cached);
#print "cached=|$hcached|\n";
		if ($cached eq $qs) {
#print "match\n";
			$resfile = $query;
			$resfile =~ s:/query:/result: ;
#print "resfile=$resfile\n";
			if (open(SELECTION,"<$resfile")) {
				return 1;
			}
		}
#print "no file\n";
	}
#print "no hit\n";
	return 0;
}

$title = 'Gran Turismo Car Finder Results';
print "Content-Type: text/html\nPragma: no-cache\n\n<html><head><title>\n";
print "$title</title></head><body bgcolor=\"yellow\">\n";


$fields = "";
$sortby = "";
$reverse = 0;

$sortby = (defined($q'sortby)? $q'sortby : $sortby);
$fields = (defined($q'fields)? $q'fields : $fields);
$reverse = (defined($q'r)? $q'r : $reverse);
if (defined($q'f)) {
	$fields = $fields ? $fields . ",$q'f" : $q'f;
}
if (defined($q's)) {
	$sortby = $sortby ? $sortby . ",$q's" : $q's;
}
if ($reverse) {
	# all-or-nothing sort reversal
	$sortby =~ s/,/,-/g;
	$sortby =~ s/^./-$&/;
	# some what mediated by non-reverse sort on select fields
}

#
# Based on multiple instances of field t,q,op,v, we should be able
#   to construct an arbitrary number of queries
#

@types = ();
@queries = ();
@ops = ();
@vals = ();
@nots = ();

# add an extra "types" to clean up input form...
@types = ("", ( defined($q't) ? split(/,/,$q't) : () ) );
@queries = split(/,/,$q'q) if defined($q'q);
@nots = split(/,/,$q'n) if defined($q'n);
@ops = split(/,/,$q'op) if defined($q'op);
@vals = split(/,/,$q'v) if defined($q'v);

$limit = 200;
$limit = $q'limit if defined($q'limit);
if ($limit > 200) {
	# no, really limit user to 200 *lines* of output
	#  (not exactly same as 200 matches)
	#$limit = 200;
}

$qstring = "";
@qargs = ();
push @qargs,"limit=$limit";
push @qargs,"output=web";
push @qargs,"field=$fields";
push @qargs,"sortby=$sortby";
for ($i = 0; $i <= $#vals; ++$i) {
	last if ($vals[$i] eq "");
	last unless (defined $queries[$i] && $queries[$i] ne "");
	last unless (defined $ops[$i] && $ops[$i] ne "");
	$tstring = "";
	$tstring = "$types[$i]" if (defined $types[$i]);
	$tstring =~ s/[']/'"'"'/g;
	$tstring = " '$tstring'" if ($tstring);
	$qstring .= $tstring;
	push @qargs, "$types[$i]" if (defined $types[$i]);
	$tstring = "$queries[$i]";
	$tstring .= "!" if (defined $nots[$i] && $nots[$i]);
	$tstring .= "$ops[$i]$vals[$i]";
	push @qargs, "$tstring";
	$tstring =~ s/[']/'"'"'/g;
	$tstring = " '$tstring'";
	$qstring .= $tstring;
		
}

#
# following will need to be replaced by an execl to avoid interpretation
#   of strings...
#
#$output=`/bin/cat /u/arpepper/public_html/gt/inventory/total.connoy | /u/arpepper/public_html/gt/inventory/select limit=$limit output=web "field=$fields" "sortby=$sortby" "$type1" "$search1" "$type2" "$search2" "$type3" "$search3" "$type4" "$search4" "$type5" "$search5"`;
#$output=`/bin/cat /u/arpepper/public_html/gt/inventory/total.connoy | /u/arpepper/public_html/gt/inventory/select limit=$limit output=web "field=$fields" "sortby=$sortby" $qstring`;


if (&cached_demo($web'query)) {
	# will have opened <SELECTION>

}
else {
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
		($sec,$min,$hour,$mday,$mon,$yr,$wday,$yday,$isdst) =
			localtime(time);
		$tmin = $hour*60 + $min;
		$weekday = ("Sun","Mon","Tues","Wed","Thurs","Fri","Sat")[$wday];
		$weekday .= "day";
		if ( $wday != 0 && $wday != 6 &&
			 $wday == 7 &&
			(8*60 + 30) <= $tmin && $tmin <= (16*60 + 30 )) {
			print "<p>Sorry, this service is only available outside working hours, that is before 8:30AM Eastern Time or after 4:30PM.</p>\n";
			print "<p>Please try again then.</p>\n";
			printf("<p>Current Eastern time is %d:%2.2d:%2.2d  %s</p>\n",
				$hour,$min,$sec, $weekday);
			print "<table>\n";
			print "</table>\n";
			exit 0;
		}
		close(STDIN);
		unless (open(STDIN,"<./total.connoy")){
			die "cannot open STDIN total.connoy";
		}
		close(STDERR);
		#dup2(STDOUT,STDERR);
		#print STDERR "And away we go...";
		exec "./select", (@qargs);
		die "exec failed $!";
	}
	#=================================================================
}

$debug_output="";
#$q'debug = 1;
if (defined($q'debug)) {
	$query = "";
	$query = $web'query  if (defined($web'query));
	$query = &web'htmlencode($query);
	$debug_output = `/bin/csh -c limit`;
	$debug_output .= <<EOF
<p>
\$q't=$q't<br>
\$q'q=$q'q<br>
\$q'n=$q'n<br>
\$q'op=$q'op<br>
\$q'v=$q'v<br>
\$qstring=$qstring<br>
<br>
$query<br>
<br>
\$fields=$fields <br>
\$sortby=$sortby <br>
</p>
EOF
}


#<base href="http://www.math.uwaterloo.ca/~arpepper/gt/inventory/">
print <<EOF  ;
<table width="100%" bgcolor="black">
<tr color="white">
<td>
<font color="white">
<h3><img src="../../gifs/gtlogo.jpg" alt="Gran Turismo"> Car Finder Results</h3>
</font>
</td>
</table>
<p>
To contact the author by
<a href="../email.html">email</a>.
</p>
<p>
Bewildered?  See if the
<a href="tutorial.html">tutorial</a> helps.
</p>
$debug_output
<p>Results of your query:
</p>
EOF

$intable = 0;
while (<SELECTION>) {
	print $_;
	$output = $_;
	if ($output =~ /<table/o ) {
		$intable = 1;
	}
}
close(SELECTION);

if ($output !~ /<\/table/s ) {
	print ">\n</table>\n" if ($intable);
	print <<EOF;
<p>
<b> *** ERROR ***
Something went wrong with the query engine, and it returned
invalid or incomplete output.
</b>
</p>
<p>
You probably entered a query which caused the program to exceed its
CPU time limit.
Try something less complicated which generates less output.
</p>
<p>
In particular, since sorting is the most expensive step, specify at least one restriction which greatly
reduces the number of selected items; e.g. restrict Manufacturer,
or horsepower, etc.
Reducing the number of columns in the result can help too.
</p>
EOF
}

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
		if ($valname eq "v") {
			if (defined($vals[0])) {
				$vals[0] =~ s/"//g;
				$line =~ s/(value=")[^"]*/$1$vals[0]/;
				shift @vals;
			}
		}
		elsif ($valname eq "limit") {
			if (defined($limit)) {
				$limit =~ s/"//g;
				$line =~ s/(value=")[^"]*/$1$limit/;
			}
		}
	}
	elsif ($line =~ /^\s*<option value="([^"]*)/ ) {
		$val = $1;
		if ($selname eq "q") {
			if ($val eq $queries[0]) {
				$line =~ s/>/ selected>/;
			}
		}
		elsif ($selname eq "t") {
			if (defined($types[1]) && $val eq $types[1]) {
				$line =~ s/>/ selected>/;
			}
		}
		elsif ($selname eq "op") {
			if ($val eq $ops[0]) {
				#  a value we like is ">"   8-)
				$line =~ s/>[^"]/ selected$&/;
			}
		}
		elsif ($selname eq "n") {
			if ($val eq $nots[0]) {
				$line =~ s/>/ selected>/;
			}
		}
		elsif ($selname eq "f") {
			$line =~ s/ selected>/>/;
			if (defined($farray[0]) && $val eq $farray[0]) {
				$line =~ s/>/ selected>/;
				shift @farray;
			}
		}
		elsif ($selname eq "s") {
			$line =~ s/ selected>/>/;
			if (defined($sarray[0]) && $val eq $sarray[0]) {
				$line =~ s/>/ selected>/;
				shift @sarray;
			}
		}
		elsif ($selname eq "r") {
			if ($val eq $reverse) {
				$line =~ s/>/ selected>/;
			}
		}
	}


	return $line;
}

if (open(SELECTION,"< ./findcar.html")) {
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
