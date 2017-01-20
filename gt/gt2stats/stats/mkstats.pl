#!/usr/bin/perl -w

sub
stb {
	my($string) = @_;

	$string =~ s/ *$//;
	$string =~ s/^--+$/-/;
	return $string;
}

sub
output_internal {
	my($string) = @_;

	$string =~ s/ *$//;
	$string =~ s/^--+$/-/;
	$string = "-" if $string eq "";
	print '"';
	print $string;
	print '",';
}

sub
output_last {
	my($string) = @_;

	$string =~ s/ *$//;
	$string =~ s/^--+$/-/;
	$string = "-" if $string eq "";
	print '"';
	print $string;
	print '")';
}

print <<_EOF ;
// Original content copyright (c) 2001 Adrian Pepper, all rights reserved.
// Contact arpepper at math.uwaterloo.ca  for more information.

var fieldnames =
new Array( "Country","Manufacturer","Model Name","&nbsp;","&nbsp;","Tuned MinHP", "NA MaxHP", "Turbo MaxHP", "Tuned Wt.", "Racing Wt." );
var colnames =
new Array( "Country","Manufacturer","Model Name","Drive Train","Aspiration","Minimum Tuned BHP", "Maximum BHP (Normally Aspirated)", "Maximum BHP (Turbocharged)", "Tuned Weight", "Racing Weight" );

_EOF

print "var cardata = new Array(\n";
$flag = 0;
while ( <> ) {
	$_ =~ s/\n//g;
	next if $_ =~ /^\s*$/;
	next if $_ =~ /^\s/;
	next if $_ =~ /^========/;
	next if $_ =~ /^---*$/;
	next if $_ =~ /^\d+ entr/;
	if ($_ =~ /^Country: ([^(]*\s*)\(/) {
		# Country: USA (South City)
		$country = $1;
		next;
	}
	if ($_ !~ /^.{60}/) {
		$mfr = $_;
		next;
	}
	if ($flag) {
		print ",\n";
	}
	# must be a regular car line
# Country: Germany (North City)            Drv A Tuned NA    Turbo Tuned Racing
# 8 entries                                Trn   MinHP MaxHP MaxHP Wt.   Wt.
# =============================================================================
# 123456789*123456789*123456789*123456789*123456789*123456789*123456789*1234567
# Golf IV GTI                              FF  N 129   269   305   2491  2389
	$_ =~ /^(.{40}) (.{3}) (.) (.{5}) (.{5}) (.{5}) (.{5}) (.*)/;
	$name  = &stb($1);
	$drv   = &stb($2);
	$asp   = &stb($3);
	$minhp = &stb($4);
	$nahp  = &stb($5);
	$turhp = &stb($6);
	$tunwt = &stb($7);
	$racwt = &stb($8);
	print "new Array(";
	&output_internal($country);
	&output_internal($mfr);
	&output_internal($name);
	&output_internal($drv);
	&output_internal($asp);
	&output_internal($minhp);
	&output_internal($nahp);
	&output_internal($turhp);
	&output_internal($tunwt);
	&output_last($racwt);
	$flag = 1;
}
if ($flag) {
	print "\n";
}
print ");\n";
