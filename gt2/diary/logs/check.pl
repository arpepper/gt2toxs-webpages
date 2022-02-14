#!/usr/bin/perl -w

require 5.002;
use strict;

sub
warn {
	print @_;
}

$main::mintoday = 0;
$main::maxtoday = 1;

@main::cardata = ();   # now we initialize all data via "mod car" in the log

@main::racedata = (
  "Sunday",      3, "Demio", "", "", "", "", "", "", "",
  "Clubman",     3, "Camaro", "", "", "", "", "", "", "",
  "GTC",         4, "ChaserLM", "", "", "", "", "", "", "",
  "GTI",         6, "credits", "", "", "", "", "", "", "",
  "FF",          3,
       "CRX", "yellow","blue","black",   "Celica","green","yellow","purple",
  "FR",          3,
       "S13Silvia", "green","yellow","red", "SilEighty", "yellow","blue","dkBlue",
  "4wd",         3,
       "Lancer", "green","yellow","purple", "Alcyone", "blue","white", "dkBlue",
  "Lwt",         3,
       "Civic", "yellow","blue","pink",  "Eunos", "blue","yellow","gold",
  "USvsJP",      5,
       "Viper", "WgreenSt","WblueSt","", "FTO", "black", "green", "",
  "UKvsJP",      5,
       "Cerbera", "purple", "green","",  "delSol", "black ", "red ", "",
  "UKvsUS",      5,
       "RX7","green","blue","",          "ConceptCar", "purple","yellow","",
  "Mega",        3,
       "DB7", "white","red","purple",  "Soarer", "yellow","purple","redOrange",
  "Normal",      5,
      "Impreza","blue","yellow","orange", "SupraRZ","ltBlue","purple","orange",
  "Tuned",       5,
       "Trueno", "white","pink","blue", "Skyline", "red","yellow","blue",
  "Abnormal",    5,
       "Trueno", "white","pink","blue", "Skyline", "red","yellow","blue",
  "GV300",       1, "Supra", "black/blue", "black/green", "", "", "", "", "",
  "All-nightI",  1, "SilviaLM", "red", "green", "", "", "", "", "",
  "All-nightII", 1, "NismoGT-R LM", "silver", "", "", "", "", "", "",
);
@main::racelist = ();

sub
cc {
	my($colour,$car) = @_;

	if ($colour =~ /^W/) {
		$car . $colour;
	}
	else {
		$colour . $car;
	}
}
		

my($name,$length,$car1,$c1,$c2,$c3,$car2,$d1,$d2,$d3,$pstring);
while (@main::racedata) {
	$name = shift @main::racedata;
#print "$name\n";
	$length = shift @main::racedata;
	$car1 = shift @main::racedata;
	$c1 = shift @main::racedata;
	$c2 = shift @main::racedata;
	$c3 = shift @main::racedata;
	$car2 = shift @main::racedata;
	$d1 = shift @main::racedata;
	$d2 = shift @main::racedata;
	$d3 = shift @main::racedata;
	if ( $length =~ /\D/ ) {
		die "sync error in racedata: $name\n";
	}
	$pstring = "," . &cc( $c1 , $car1 ) . ",";
	if ( $c2 ne "" ) {
		$pstring .= &cc( $c2 , $car1 ) . ",";
	}
	if ( $c3 ne "" ) {
		$pstring .= &cc( $c3 , $car1 ) . ",";
	}
	if ( $d1 ne "" ) {
		$pstring .= &cc( $d1 , $car2 ) . ",";
	}
	if ( $d2 ne "" ) {
		$pstring .= &cc( $d2 , $car2 ) . ",";
	}
	if ( $d3 ne "" ) {
		$pstring .= &cc( $d3 , $car2 ) . ",";
	}
#print "${name}:$pstring\n";
	
	push @main::racelist , $name;
	$main::racelength{$name} = $length;
	$main::raceprizes{$name} = $pstring;
};
while (@main::cardata) {
	$name = shift @main::cardata;
	$main::carlist{$name} = $name;
};

sub
daycheck {
	my($day) = @_;

	if ($day < $main::mintoday || $main::maxtoday < $day) {
		return 0;
	}
	return 1;
}

sub
dodateline {
	my($line) = @_;

	if ($line !~ /1999/ && $line !~ /2000/) {
		&warn("Bad date line: $_\n");
	}
}

sub
dolicenseline {
	my($line,$start,$end) = @_;
	my($diff);

#&warn("Good license line:$_\n");
	if (!&daycheck($start) ) {
		&warn("Bad license start day(not ${main::maxtoday}): $_\n");
	}
	$diff = $end - $start;
	if ( $diff < 0 ) {
		&warn("Bad license end day: $_\n");
	}
	$main::mintoday = $end + 1;
	$main::maxtoday = $end + 1;

}

sub
otherprize {
	my($prize) = @_;

	return 1 if ($prize eq "full");
	return 1 if ($prize eq "none");
	return 1 if ($prize eq "8-");   #  8-(
	return 0;
}

sub
doseriesline {
	my($line,$start,$end) = @_;
	my($diff);
	my($rest,$i,$none,$pat,$race,$length,$prev,$after);
	my($car,$prize);

	if (!&daycheck($start) ) {
		&warn("Bad start day(not ${main::maxtoday}): $_\n");
	}
	$diff = $end - $start;
	if ( $diff < 0 || 6 < $diff) {
		&warn("Bad end day: $_\n");
	}
	$main::mintoday = $end + 1;
	$main::maxtoday = $end + 1;
	$rest = $line;
	$rest =~ s/^\s*(\d+)-(\d+)\s*//;
	$none = 1;
	$length = 6;
look:
	foreach $i (@main::racelist) {
		if ( $rest =~ /\s${i}\s/ ) {
			$none = 0;
			$rest =~ /(.*\s)(${i})(\s.*)/;
			($prev,$race,$after) = ($1,$2,$3);
			$length = $main::racelength{$race};
			last look;
		}
	}
	if ($none) {
		&warn("Unrecognized race: $_\n");
	}
	else {
		if ($diff != $length) {
			&warn("Bad end day for series \"$race\": $line\n");
		}
		$car = $prev;
		$car =~ s/^\s*//;
		$car =~ s/[,\s].*//;
		if (!defined($main::carlist{$car}) ) {
			&warn("Unrecognized car ($car): $line\n");
			$main::carlist{$car} = $car;
		}
		
	}
	$prize = $rest;
	$prize =~ s/red /red#/g;
	$prize =~ s/black /black#/g;
	$prize =~ s/ LM/#LM/g;
        $prize =~ s/^.* (\w)/$1/;
        $prize =~ s/[(].*//;
        $prize =~ s/[!]//g;
	if ($prize !~ /ConceptCar/) {
		$prize =~ s/Concept/ConceptCar/;
	}
	$prize =~ s/#/ /g;
	if ( &otherprize($prize) == 0 &&
			$main::raceprizes{$race} !~ /,${prize},/ ) {
		&warn("Unrecognized prize ($prize) for $race: $line\n");
	}
	else {
		$main::carlist{$prize} = $prize;
	}
}

sub
do1dayline {
	my($line,$day) = @_;

	&warn("Unknown single day event: $_\n");
	if (!&daycheck($day) ) {
		&warn("Bad single day event(not ${main::maxtoday}): $_\n");
	}
	$main::mintoday = $day;
	$main::maxtoday = $day + 1;
}

sub
dodaynote {
	my($line,$day) = @_;
	my($stuff);

	$line =~ /^\s*(\d+)/;
if ( !defined($1) ) {
print $line,"\n";
}
	$day = $1;
	if (!&daycheck($day) ) {
		&warn("Bad single day note(not ${main::maxtoday}): $_\n");
	}
	$main::mintoday = $day;
	$main::maxtoday = $day;
	# grr... seems difficult to undef $1 ...
	if ($line =~ /^\s*(\d+)\s+buy\s+(.*)/ && defined($2)) {
		$stuff = $2;
#print "stuff:$stuff\n";
		if ($stuff =~ /^\s*car\s+(\S+)/ && defined($1) ) {
			$main::carlist{$1} = $1;
		}
		elsif ($stuff =~ /^\s*parts\s+/) {
			;
		}
		else {
			&warn("Bad purchase: $line\n");
		}
	}
	if ($line =~ /^\s*(\d+)\s+mod\s+(.*)/ && defined($2)) {
		$stuff = $2;
#print "stuff:$stuff\n";
		if ($stuff =~ /^\s*car\s+(\S+)/ && defined($1) ) {
			$main::carlist{$1} = $1;
		}
		else {
			&warn("Bad mod: $line\n");
		}
	}
}

sub
donote {
	my($line) = @_;

}

while (<>) {
	my($line) = $_;
	my($license,$r1,$r2);

	$line =~ s/\n//g;
	$license = $line;
	$license =~ s/^.{10}//;
	$license =~ s/(\S+)\s.*/$1/;
	$r1 = "";
	$r2 = "";
	if ( $line =~ /^[A-Z]/) {
		;
	}
	elsif ( $line =~ /^([ \d]{3,3}\d)\-(\d[ \d]{3,3})/ ) {
		$r1 = $1;
		$r2 = $2;    # n.b. must grab all $N before doing other subs
		$r1 =~ s/\s//g;
		$r2 =~ s/\s//g;
	}
	elsif ( $line =~ /^([ \d]{3,3}\d)[ ]{6,6}/ ) {
		$r1 = $1;
		$r1 =~ s/\s//g;
		$r2 = $r1;
	}

	if ( $line =~ /^[A-Z]/) {
		&dodateline($line);
	}
	elsif ( $r1 ne "" &&
		( $license =~ /[AB][1-8]/ || $license =~ /IA[1-8]/ ) ) {
		&dolicenseline($line,$r1,$r2);
	}
	elsif ( $line =~ /^[ \d]{3,3}\d-\d[ \d]{3,3}/ ) {
		&doseriesline($line,$r1,$r2);
	}
	elsif ( $line =~ /^[ \d]{4,4}\d[ ]{6,6}/ ) {
		# this should not occur any more;  all licenses
		&do1dayline($line,$r1,$r2);
	}
	elsif ( $line =~ /^[ ]{2,3}\d{1,5}/ ) {
		&dodaynote($line);
	}
	elsif ( $line =~ /^\s{0,20}\d/ ) {
		&warn("Unrecognized line: $line\n");
	}
	else {
		&donote($line);
	}
}
