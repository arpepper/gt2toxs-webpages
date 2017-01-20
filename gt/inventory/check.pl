#!/xhbin/perl5 -w

$mfcr = "";

$check = 0;  # if set, perform check function
$merge = 0;  # if set, perform merge function
$dofullseq = 0;   # if set, complain for all cars without sequence numbers

sub
warn {
	local ($mesg) = @_;

	if ($check) {
		local ($desc) = "";
		$desc .= "$model:" if ($model);
		$desc .= "$colour:" if ($colour);
		print "$mfcr:$desc$mesg";
	}
}

$maxslot = 0;
$maxday = 0;

$islot0 = 0;

sub
nextday {
	local($day) = @_;

	if ($day == 0 ) {
		$day = 1;
	}
	else {
		$day = int($day/10) * 10 + 10;
	}
	return $day;
}

sub
dayslotindex {
	local($day,$slot) = @_;
	local ($index);

	# assuming no mfcr will have more than 100 slots
	$index = $day*100 + $slot;
	return $index + 0;
}

#
# clear all arrays at start of a new manufacturer
#
sub
clear {
	local ($day, $slot);

	#for ($day = 1; $day <= $maxday; $day = &nextday($day) ) {
	#	for ($slot = 0; $slot <= $maxslot; ++$slot) {
	#		$dayslot[&dayslotindex($day,$slot)] = "";
	#	}
	#}
	@dayslot = ();
	@allseqno = ();
	@dayseqno = ();
	$maxday = 0;
	$maxslot = 0;
	$islot0 = 0;
	
}

$prevday = -1;
$loprice = 3450;
$hiprice = 79999;

sub
add {
	local($mfcr,$model,$colour,$seqno,$info) = @_;

	local($string,$daystring,$day,$slot,$price);

	#
	#  Perhaps we should split this routine into check, and add
	#
	($daystring,$slot,$price) = split(/[\/]/,$info);
	$day = $daystring;
	if ($day eq "N" || $day eq "P" || $day eq "S") {
		# could be messy; use day 0 for new cars
		$day = 0;
		if ($slot != 0) {
			&warn("Slot should be zero $mfcr day $daystring slot $slot\n");
			$slot = 0;
		}
	}
	$day += 0;
	$slot += 0;
	$price += 0;
	if ( $slot != 0 && defined( $daymaxslot[$day] ) ) {
		if ( $slot <= $daymaxslot[$day]) {
			&warn("$info:new slot $slot <= $daymaxslot[$day]\n");
		}
	}
	$daymaxslot[$day] = $slot;
	if (defined($seqno) && $seqno != 0) {
		if (defined ($dayseqno[&dayslotindex($day,$slot)]) ) {
			local($temp);
			$temp = $dayseqno[&dayslotindex($day,$slot)];
			&warn("Duplicate sequence number for $mfcr day $day slot $slot: $temp\n");
		}
		else {
			$dayseqno[&dayslotindex($day,$slot)] = $seqno;
		}
	}
	if ( $day == 1 ) {
		;
	}
	elsif ( $day == 0 && $slot == 0) {
		;
	}
	elsif ( $day > 0 && int($day/10) * 10 == $day && $slot != 0) {
		;
	}
	else {
		&warn("Bad day number \"$day\".\n");
		$day = &nextday($day);
	}
	if ($day <= $prevday) {
		&warn("day $day is not greater than day $prevday\n");
	}
	else {
		$prevday = $day;
	}
	if ($day != 0 && $price < $loprice) {
		&warn("price $price is less than ${loprice}.\n");
	}
	if ($day != 0 && $price > $hiprice) {
		&warn("price $price is greater than ${hiprice}.\n");
	}
	if ( $price % 10 != 0 ) {
		&warn("price $price is not a multiple of 10.\n");
	}
	if ($day > $maxday) {
		$maxday = $day;
	}
	if ($slot > $maxslot) {
		$maxslot = $slot;
	}
	$string = $mfcr . ":" . $model . ":" . $colour . ":" . $price;
	if ($slot != 0) {
		if (defined ($dayslot[&dayslotindex($day,$slot)]) ) {
			local($temp);
			$temp = $dayslot[&dayslotindex($day,$slot)];
			&warn("Duplicate entry for $mfcr day $day slot $slot: $temp\n");
		}
		else {
			$dayslot[&dayslotindex($day,$slot)] = $string;
		}
	}
	else {
		# slot 0 special for new cars, prize cars, and special models
		$slot0[$islot0++] = $string;
	}
}

sub
middlecheck {
	# called at end of a record for a model
        # we actually can't think of anything we need to do here right now...
}

#
# called at the end of each manufacturer
#
sub
finalcheck {
	local ($day, $slot);
	local ($some);
	local ($pseqno,$dsix,$dseqno,$dsd,$type);

	$model = "";
	$colour = "";
	@some = ();

	$allmfcr .= "${mfcr}.";
	if ($check) {
		print "\nfinalcheck $mfcr $maxday $maxslot\n";
	}
	for ($day = 0; $day <= $maxday; $day = &nextday($day)) {
		for ($slot = 2; $slot <= $maxslot; ++$slot) {
			if ( defined($dayslot[&dayslotindex($day,$slot)]) ) {
				$some[$day] = 1;
				++$carcount[$day];
				if ( !defined($dayslot[&dayslotindex($day,$slot-1)]) ||
					$dayslot[&dayslotindex($day,$slot-1)]  eq "" ) {
					local($pslot) = $slot - 1;
					&warn("missing data for $mfcr day $day slot $pslot\n");
				}
			}
		}
	}
	if ($check) {
		for ($day = 0; $day <= $maxday; $day = &nextday($day)) {
			if ($some[$day]) {
				$mfcrlist[$day] .= "${mfcr}.";
				$pseqno = 0;
				for ($slot = 1; $slot <= $maxslot; ++$slot) {
					$dsix = &dayslotindex($day,$slot);
					$dseqno = $dayseqno[$dsix];
					if (defined($dseqno) && $dseqno != 0) {
						if ($dseqno <= $pseqno) {
							&warn(" day $day slot $slot seqno $dseqno <= $pseqno\n");

						}
						$pseqno = $dseqno;
					}
				}
			}
		}
		print "\n";
	}
	
	if ($merge) {
		for ($day = 0; $day < $islot0; ++$day) {
			$dsd = $slot0[$day];
			$dsd =~ s/,/:/;
			$type = "N";
			$type = "S" if $dsd =~ /:500000$/;
			$type = "P" if $dsd =~ /:0$/;
			printf("%s:%4.4d:%2.2d:%s\n", $type, 0,0, $dsd );
		}
		for ($day = 1; $day <= $maxday; $day = &nextday($day)) {
			for ($slot = 0; $slot <= $maxslot; ++$slot) {
				$dsix = &dayslotindex($day,$slot);
				if ( defined($dayslot[$dsix]) &&
						$dayslot[$dsix] ne "" ) {
					$dsd = $dayslot[$dsix];
					$dsd =~ s/,/:/;
					printf("U:%4.4d:%2.2d:%s\n",
						$day,$slot,
						$dsd );
				}
			}
		}
	}
	if ($check) {
		print "\n";
	}
}


#
# main
#
	

while ($ARGV[0] =~ /^\-/ )  {
	local ($option) = ($ARGV[0]);
	shift(@ARGV);
	
	if ($option =~ /^\-check/i ) {
		$check = 1;
	}
	elsif ($option =~ /^\-seq/i ) {
		$dofullseq = 1;
	}
	elsif ($option =~ /^\-merge/i ) {
		$merge = 1;
	}
	else {
		die "bogus option $option\n";
	}
}
if ( $check == 0 && $merge == 0 ) {
	$check = 1;
}


&clear();
while ( <> ) {
	local ($line) = $_;
	local ($meat,$f,$i,$stockr,$tuner,$racer);

	$line =~ s/\n//g;
	$meat = $line;
	$meat =~ s/^\s*//;
	$meat =~ s/\s*$//;
	
	if ( $line =~ /^\S+/ ) {
		if ( $mfcr ne "" ) {
			&finalcheck();
		}
		$mfcr = $line;
		$model = "";
		$colour = "";
		$seqno = 0;
		&clear();
		if ( $check) {
			print("mfcr=$mfcr\n");
		}
	}
	elsif ( $model eq "" && $meat !~ /[\/]$/ && $meat =~ /\S/ ) {
		$model = $meat;
		$model =~ s/   */,/;
		while ( $model =~ /,.* / ) {
			$model =~ s/,(\S*)  */,$1,/;
		}
		@f = split(/,/,$model);
		for ($i = 0; $i < 9; ++$i) {
			if (!defined($f[$i])) {
				$f[$i] = "-";
			}
		}
		if ($f[3] eq "-" || $f[5] eq "-" ) {
			$stockr = "-";
		}
		else {
			$stockr = sprintf("%5.3f", $f[3] / $f[5]);
			$stockr =~ s/^0//;
		}
		if ($f[4] eq "-" || $f[6] eq "-" ) {
			$tuner = "-";
		}
		else {
			$tuner = sprintf("%5.3f", $f[4] / $f[6]);
			$tuner =~ s/^0//;
		}
		if ($f[4] eq "-" || $f[7] eq "-" ) {
			$racer = "-";
		}
		else {
			$racer = sprintf("%5.3f", $f[4] / $f[7]);
			$racer =~ s/^0//;
		}
		$model = "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$f[6],$f[7],$stockr,$tuner,$racer,$f[8]";
	}
	elsif ( $meat =~ /[\/]/ ) {
		if ( $model eq "" ) {
			&warn("Data line \"$line\" before model\n"); 
		}
		if ($colour eq "" ) {
			&warn("Data line \"$line\" before colour\n"); 
		}
		if ( $meat !~ /[\/]$/ ) {
			&warn("Data line \"$line\" missing /\n"); 
		}
		&add($mfcr,$model,$colour,$seqno,$meat);
	}
	elsif ( $meat eq "" ) {
		$model = "";
		@daymaxslot = ();
		&middlecheck();
	}
	else {
		$prevday = -1;
		# must be colour line
		if ( $meat =~ /[A-Z]/ ) {
			&warn("Capital letters in colour \"$meat\"\n");
		}
		($colour,$seqno) = split(/:/,$meat);
		if (defined($seqno) && $seqno != 0) {
			$seqno += 0;
			if (defined ($allseqno[$seqno])) {
				&warn("Duplicate seqno $seqno\n");
			}
			else {
				# this is an easy one for an editor to find
				$allseqno[$seqno]  = 1;
			}
		}
		else {
			if ($dofullseq) {
				&warn("No sequence number\n");
			}
		}
	}
}
if ( $mfcr ne "" ) {
	&finalcheck();
}

if ($check) {
	for ($day = 0; $day <= $maxday; $day = &nextday($day)) {
		if ( defined($carcount[$day]) && $carcount[$day] > 0) {
			if ($mfcrlist[$day] ne $allmfcr) {
				if ($carcount[$day] > 5) {
					print "One or more manufacturers missing cars for day $day.\n";
					$temp = $mfcrlist[$day];
					print "List is $temp\n";
				}
				else {
					print "$mfcrlist[$day] have cars for day $day\n";
				}
			}
		}
	}
}
