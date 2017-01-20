#!/usr/bin/perl
while (<>) {
	$line = $_;
	$hp = $line;
	$hp =~ m/ (\d\d\d)hp /;
	$hp = $1;
	$lb = $line;
	$lb =~ m/ (\d\d\d\d)lb/;
	$lb = $1;
	$rat = $hp / $lb;
	$mrat = $rat / .454;
	$line =~ s/\n//g;
	printf("%s (%.3fhp/lb) (%.3fhp/kg)\n", $line, $rat, $mrat);
}

