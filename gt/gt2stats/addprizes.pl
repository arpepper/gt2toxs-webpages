#!/xhbin/perl5

while (<>) {
	last if ($_ !~ /^"/);
	$_ =~ s/\n//g;
	($car,$prize) = split(/,/);
	$hash{$car} = $prize;
	$seen{$car} = 0;
}
while (<>) {
	print;
	last if ($_ =~ /cardata/);
}

# new Array("USA","Acura","Acura Integra GS-R '95","1995","FF","N","178","285","-","2453","-","NO-EVENT"),
while (<>) {
	if ($_ =~ /^new Array/) {
		$_ =~ /^[^,]*,[^,]*,([^,]*)/;
		$car = $1;
		if (defined($hash{$car})) {
			$seen{$car} = 1;
			s/"NO-EVENT"/$hash{$car}/;
		}
	}
	print;
}

foreach $k (sort keys seen) {
	if ($seen{$k} == 0) {
		print "*** $car not seen?\n";
	}
}
