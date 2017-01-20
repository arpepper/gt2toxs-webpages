#!/xhbin/perl5 -w
sub
setbasetime {
	local($line) = @_;

	$mode = "";
	if ($line =~ /.*([12]-[012345]\d:\d\d[.]\d).*/ ) {
		$basetime = $1;
		$basetime =~ /([12])-([012345]\d):(\d\d)[.](\d)/;
		$hours = $1;
		$minutes = $2;
		$seconds = $3;
		$tenths = $4;
		$mode = "hours";
#printf("%d-%2.2d:%2.2d.%d\n", $hours, $minutes, $seconds, $tenths);
	}
	elsif ($line =~ /.*\D+(\d\d?:[012345]\d[.]\d\d\d).*/ ) {
		$basetime = $1;
		$basetime =~ /(\d\d?):([012345]\d)[.](\d\d\d)/;
		$hours = 0;
		$minutes = $1;
		$seconds = $2;
		$thous = $3;
		$mode = "minutes";
	}
	return $mode;
}

sub
fulltime {
	local($line) = @_;
	local($iseconds,$ithous,$incr,$sign);
	local($nhours,$nminutes,$nseconds,$ntenths,$nthous,$carry);

	if ($line =~ /([+\-])(\d\d*).(\d\d\d)/ ) {
		$incr = $1;
		$iseconds = $2;
		$ithous = $3;
	}
	elsif ($line =~ /([+\-])(\d+):(\d\d*).(\d\d\d)/ ) {
		$incr = $1;
		$iseconds = $2 * 60 + $3;
		$ithous = $4;
	}
	$sign = 1;
	$sign = -1 if ($incr eq "-");

	if ($mode eq "hours") {
		$carry = 0;
		$ntenths = int( ($ithous + 50) / 100);
		$ntenths *= $sign;
		$ntenths += $tenths;
		while ($ntenths < 0) {
			$ntenths += 10;
			--$carry;
		}
		while ($ntenths >= 10) {
			$ntenths -= 10;
			++$carry;
		}
		$nseconds = $sign * $iseconds + $seconds + $carry;
		$carry = 0;
		while ($nseconds < 0) {
			--$carry;
			$nseconds += 60;
		}
		while ($nseconds >= 60) {
			++$carry;
			$nseconds -= 60;
		}
		$nminutes = $minutes + $carry;
		$carry = 0;
		while ($nminutes < 0) {
			--$carry;
			$nminutes += 60;
		}
		while ($nminutes >= 60) {
			++$carry;
			$nminutes -= 60;
		}
		$nhours = $hours + $carry;
		
		return sprintf("%d-%2.2d:%2.2d.%d",$nhours,$nminutes,$nseconds,$ntenths);
	}
	else {
		$carry = 0;
		$nthous = $thous + $ithous * $sign;
		while ($nthous < 0) {
			$nthous += 1000;
			--$carry;
		}
		while ($nthous >= 1000) {
			$nthous -= 1000;
			++$carry;
		}
		$nseconds = $iseconds * $sign + $seconds + $carry;
		$carry = 0;
		while ($nseconds < 0) {
			--$carry;
			$nseconds += 60;
		}
		while ($nseconds >= 60) {
			++$carry;
			$nseconds -= 60;
		}
		$nminutes = $minutes + $carry;
		
		return sprintf("%2.2d:%2.2d.%3.3d",$nminutes,$nseconds,$nthous);
	}
}

$basetime = "";
while (<>) {
	$line = $_;
	if ( $basetime ne "" ) {
		if ($line =~ /[+\-]\d\d*.\d\d\d/ ) {
			$fintime = &fulltime($line);
			$line =~ s/\n//;
			print $line, "  ", $fintime, "\n";
		}
		elsif ($line =~ /[+\-]\d+:\d\d*.\d\d\d/ ) {
			$fintime = &fulltime($line);
			$line =~ s/\n//;
			print $line, "  ", $fintime, "\n";
		}
		else {
			print $line;
			$basetime = "";
		}
	}
	elsif ( &setbasetime($line) ) {
		print $line;
	}
	else {
		print $line;
	}
}
