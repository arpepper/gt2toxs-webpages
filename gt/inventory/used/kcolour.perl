#!/usr/bin/perl

# ./kcolour.perl colour.map > maps.tmp
# Edit maps.tmp into mkdata.perl (3 hashes).

$mfr = -1;
$carname = "UNKNOWN CAR";
print "%seencolours = (\n";
while (<>) {
	if ($_ =~ /^  [a-z]/) {
		$colour = $_;
		$colour =~ s/^ *//;
		$colour =~ s/ *$//;
		$colour =~ s/\n//g;
	}
	elsif ($_ =~ /^   \d\d\d\d\//) {
		$key = $_;
		$key =~ s/^ *//;
		$key =~ s/\n//g;
		$key =~ s:/$::g;
		$key =~ s:/(\d+)$::g;
		$price = $1;
		$key =~ s:^0001/:0000/:g;
		$key =~ s/^0//;
		$key = "$mfr/$key";
		print "\t\"$key\", \"$colour\",\n";
		@prices = (@prices, $key, $price);
		@carnames = (@carnames, $key, $carname);
	}
	elsif ($_ =~ /^ [^\s]/) {
		$carname = $_;
		$carname =~ s/^ *//;
		$carname =~ s/ *$//;
		$carname =~ s/\n//g;
		$colour = "UNKNOWN COLOUR";
	}
	elsif ($_ =~ /^[^\s]/) {
		++$mfr;
		$carname = "UNKNOWN CAR";
	}
	elsif ($_ =~ /^\s*$/) {
		;   # blank lines allowed
	}
	else {
		warn "";
		warn "Bad line: $_";
	}
}
print ");\n\n";
print "%seenprices = (\n";
while (@prices) {
	$key = shift(@prices);
	$price = shift(@prices);
	print "\t\"$key\", \"$price\",\n";
}
print ");\n\n";
print "%seennames = (\n";
while (@carnames) {
	$key = shift(@carnames);
	$carname = shift(@carnames);
	print "\t\"$key\", \"$carname\",\n";
}
print ");\n\n";
