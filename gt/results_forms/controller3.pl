#!/xhbin/perl5 -w

sub
colorof {
	local($value) = @_;
	local($front,$rear,$fhex,$rhex);

	$front = $value;
	$rear = 1 - $front;
	if ($front < 0.25 ) {
		$front = 0;
	}
	elsif ($front > 0.75) {
		$front = 1.0;
	}
	else {
		$front = 2 * ( $front - 0.25);
	}
	if ($rear < 0.25 ) {
		$rear = 0;
	}
	elsif ($rear > 0.75) {
		$rear = 1.0;
	}
	else {
		$rear = 2 * ( $rear - 0.25);
	}
	$fhex = sprintf("%2.2x", 63 * $front * 4 );
	$rhex = sprintf("%2.2x", 63 * $rear  * 4 );
	"#". $fhex . "B8" . $rhex;
}

printf("<HTML>\n<HEAD>\n</HEAD>\n<BODY>\n");
printf("<TABLE>\n");
printf("<TR><TH COLSPAN=1 BGCOLOR=\"white\"></TH>\n");
printf("<TH COLSPAN=%d BGCOLOR=\"#2F9FF9\">%s</TH></TR>\n",15,"Rear");
printf("<TR><TH BGCOLOR=\"#F99F0F\">Front</TH>\n");
for ($r = 1; $r <= 15; ++$r) {
	printf("<TH BGCOLOR=\"#2F9FF9\">%d</TH>", $r );
}
printf("</TR>\n");
for ( $f = 1; $f <= 15; ++$f) {
	printf("<TR BGCOLOR=\"#F99F0F\"><TH>%2d: </TH>\n",$f);
	for ($r = 1; $r <= 15; ++$r) {
		$v = $f / ($f + $r);
		$color = &colorof($v);
		printf("<TD ALIGN=right BGCOLOR=\"%s\">%5.1f</TD>\n", $color, 100.0 * $v );
	}
	printf("</TR>\n");
}
printf("</TABLE>\n");
printf("</HTML>\n");
