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

printf("<table border bgcolor=\"white\">");
printf("<tr><td>&nbsp;</td>");
for ($i=0; $i <= $#names; ++$i) {
	printf("<th>%s</th>", $names[$i]);
}
printf("</tr>");
for ($i=0; $i <= $#names; ++$i) {
	printf("<tr>");
	printf("<th>%s</th>", $names[$i]);

	for ($j=0; $j <= $#names; ++$j) {
		$diff = $vals[$j] - $vals[$i];
		if ($diff > 0) {
			printf("<td>+%3.3X</td>", $diff);
		}
		elsif ($diff == 0) {
			printf("<td align=\"center\">-</td>");
			
		}
		else {
			printf("<td>-%3.3X</td>", -$diff);
		}
	}
	printf("</tr>");
}
printf("</table>\n");
