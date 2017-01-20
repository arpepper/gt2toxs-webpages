#!/xhbin/perl5 -w

#
# elapsed - convert total thousandsths to a readable string
#
#   bad name for routine
#
	sub
elapsed {
	local($thous) = @_;
	local($ttt,$ss,$mm,$hh);

	$ttt = $thous;

	$hh = int($ttt / (60 * 60 * 1000) );
	$ttt -= $hh * (60 * 60 * 1000);
	$mm = int($ttt / (60 * 1000) );
	$ttt -= $mm * (60 * 1000);
	$ss = int($ttt / 1000 );
	$ttt -= $ss * 1000;

	if ($hh > 0) {
		sprintf("%d-%2.2d:%2.2d.%3.3d",$hh,$mm,$ss,$ttt);
	}
	else {
		sprintf("  %2d:%2.2d.%3.3d",$mm,$ss,$ttt);
	}
	
}

$lapcount = 0;
$totthous = 0;
while (<>) {
	if ( $_ =~ /^([ \d]{2}) *(([0123]):([0-5]\d)[.](\d{3})) *$/ ) {
		++$lapcount;
		$lap = $1;
		$time = $2;
		$mins = $3;
		$secs = $4;
		$thous = $5;
		$totthous += $thous + ( 1000 * $secs) + ( 60 * 1000 * $mins);
		if ($lap != $lapcount) {
			warn "Bad lap: $_";
		}
		
#printf("%2d   %s %d:%2.2d.%3.3d\n", $lap, $time, $mins, $secs, $thous);
		printf("%2d   %s   %s\n", $lap, $time, &elapsed($totthous) );

	}
	elsif ( $_ =~ /^([ \d]{2}) *(\+([1-9][0-9]):([0-5]\d)[.](\d{3})) *$/ ) {
		$lap = $1;
		$lapcount = $lap;
		$time = $2;
		$mins = $3;
		$secs = $4;
		$thous = $5;
		$totthous = $thous + ( 1000 * $secs) + ( 60 * 1000 * $mins);
		
#printf("%2d %s %d:%2.2d.%3.3d\n", $lap, $time, $mins, $secs, $thous);
		printf("%2d %s\n", $lap, $time );

	}
	else {
		print $_;
	}
}
