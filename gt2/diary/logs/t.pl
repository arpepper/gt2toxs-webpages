#!/xhbin/perl5

$maxd = 0;
$maxn = 0;

for ($i = 1; $i <= 1168; ++$i ) {
	$line = `./garage blue $i | tail -1` ;
	if ( $line =~ /^\s*(\d+)/ ) {
		$n = $1;
		if ($n > $maxn) {
			$maxd = $i;
			$maxn = $n;
		}
	}
	printf("%4.4i $n $maxd $maxn\n",$i);
}

print $maxd, " ", $maxn, "\n";

