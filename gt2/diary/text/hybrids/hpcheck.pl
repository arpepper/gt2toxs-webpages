#!/xhbin/perl5

sub hex {
	my($string) = @_;
	my($nmm);

	$string = oct("0x" . $string);

	$num = 0 + $string;
	return $num;
}

$baseoff = -1;
$basefrom = -1;
$baseto = -1;
$shift = 0;

sub set {
	my($to,$size) = @_;
	my($i);

	if ($to < $baseto) {
		warn sprintf("%8.8X < %8.8X\n", $to-$shift, $baseto);
	}
	elsif ($to + $size > $baseto + 164) {
		warn sprintf("%8.8X %4.4X > %8.8X\n", $to-$shift, $size, $baseto);
	}
	for ($i = $to; $i < $to + $size; ++$i ) {
		++$tick[$i];
	}
}
	

while (<>) {
	next if ($_ =~ /^\s*#/);
	if ($_ =~ /^\s*$/) {
		print "\n";
		next;
	}
	($from, $junk, $to, $size, $off, $rest) = split / +/, $_, 6;
	if (!defined($rest) || $rest eq "" ) {
		$rest = "";
	}
	else {
		$rest = " " . $rest;
	}
	$rest =~ s/\n//g;
	$xfrom = &hex($from);
	$xto = &hex($to);
	$xsize = &hex($size);
	if ($basefrom < 0) {
		$basefrom = $xfrom;
	}
	if ($baseto < 0) {
		$baseto = $xto;
		for ($i = $baseto; $i < $to + 164; ++$i ) {
			$tick[$i] = 0;
		}
	}
	if ($baseoff < 0) {
		$xoff = &hex($off);
		$baseoff = $xoff;
	}
	else {
		$xoff = &hex($off);
		if (($xoff%164) != 0) {
			warn sprintf("%3.3X not multiple of 164\n", $xoff);
		}
		$xoff += $baseoff;
	}
	if ( ($xfrom - $basefrom) != ($xto - $baseto) ) {
	 	warn "Inconsistent $from and $to\n";
	}
	$shift = $baseto - $basefrom;
	&set($xto,$xsize);
	#printf("%8.8X %8.8X %4.4X %4.4X\n", $xfrom, $xto, $xsize, $xoff);
	printf("C2%6.6X %4.4X%s\n10%6.6X %4.4X\n", $xfrom+$xoff, $xsize, $rest, $xto+$baseoff, 0);
}

for ($i = $baseto; $i < $baseto + 164; ++$i ) {
	if ($tick[$i] != 1) {
		warn sprintf("%8.8X %d\n", $i-$shift, $tick[$i]);
	}
}
