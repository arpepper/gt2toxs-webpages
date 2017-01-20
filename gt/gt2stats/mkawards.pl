#!/usr/bin/perl

# produce award listing, awards.txt, to merge into data.js

#    Awarded randomly in Super Touring Car Trophy.
#    Awarded in Muscle Car Cup Race 3.

while (<>) {
	if ($_ =~ /^ +awarded in /i ) {
		$event = $_;
		$event =~ s/\n//g;
		$event =~ s/^ +awarded in //i;
		$event =~ s/\. *$//;
		print "\"$car\",\"$event\"\n";
	}
	elsif ($_ =~ /^ +awarded randomly in /i ) {
		$event = $_;
		$event =~ s/\n//g;
		$event =~ s/^ +awarded randomly in//i;
		$event =~ s/\. *$//;
		print "\"$car\",\"$event (random)\"\n";
	}
	else {
		$_ =~ /^(.....................................)/;
		$car = $1;
		$car =~ s/ +$//;
	}
}
