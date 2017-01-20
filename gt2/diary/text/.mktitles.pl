#!/xhbin/perl5 -w

#$first = `ls [12][0-9][0-9][0-9]-*.html | head -1`;
#$last = `ls [12][0-9][0-9][0-9]-*.html | tail -1`;
$date = `date`;

#$me = $first;
#$me = $last;
$me = $date;
$me = "";

sub
flushlast {
	if ( $me ne "" ) {
		local ($base) = $me;
		$base =~ s/[.][^.]*//;
		$h3 = "" if ( ! $h3 );
		$h4 = "" if ( ! $h4 );
		$h3 =~ s/\n//mg;
		$h3 =~ s/<[^>]*>//g;
		$h4 =~ s/\n//mg;
		$h4 =~ s/<[^>]*>//g;
		print $base, ":", $h3, " -- ", $h4, "\n";
	}
	$h3 = "";
	$h4 = "";
	$me = "";

}

$me = "";
$h3 = "";
$h4 = "";

while ( <> ) {
	if ( $me ne "" && $me ne $ARGV ) {
		&flushlast;
	}
	if ( $me eq "" ) {
		$me = $ARGV;
		$myplace = $me;
		if ($myplace =~ /^\// ) {
			$myplace =~ s:[^/]*$:: ;
			$me =~ s:^.*/::;
		}
		else {
			$myplace = ".";
		}
#print $me,"\n",$myplace,"\n";
	}
	if ( $_ =~ /^\S/ ) {
		if ($h3 eq "") {
			$h3 = $_;
		}
		elsif ($h4 eq "") {
			$h4 = $_;
		}
	}
}

&flushlast;
