#!/xhbin/perl

#
# According to Fiery, deals with enhancement codes
#  body mods, traction codes, joker settings codes, etc.
#

$nt10off = 0;
$nt11off = 0x0B0;
$nt12off = 0x310;
$paloff = 0x340;
$japoff = 0x000;

@names = ("NT1.0", "NT1.1", "NT1.2", "  PAL");
@vals = ( $nt10off, $nt11off, $nt12off, $paloff);

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
