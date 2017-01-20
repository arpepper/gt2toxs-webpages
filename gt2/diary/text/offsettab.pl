#!/xhbin/perl
$nt10off = 0;
$nt11off = 0x370;
$nt12off = 0x5A0;
$paloff = 0x5D0;
$japoff = 0xA00;

@names = ("NT1.0", "NT1.1", "NT1.2", "  PAL","  JAP");
@vals = ( $nt10off, $nt11off, $nt12off, $paloff, $japoff,);

printf("     ");
for ($i=0; $i <= $#names; ++$i) {
	printf(" %s", $names[$i]);
}
printf("\n");
for ($i=0; $i <= $#names; ++$i) {
	printf("%s", $names[$i]);

	for ($j=0; $j <= $#names; ++$j) {
		$diff = $vals[$j] - $vals[$i];
		if ($diff > 0) {
			printf("  +%3.3X", $diff);
		}
		elsif ($diff == 0) {
			printf("    * ");
			
		}
		else {
			printf("  -%3.3X", -$diff);
		}
	}
	printf("\n");
}
