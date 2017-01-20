#!/xhbin/perl -w

$string = "15  14  517
14  13  519
13  12  520
12  11  522
11  10  524
10   9  526
9   8  529
8   7  533
15  13  536
14  12  538
13  11  542
12  10  545
11   9  550
15  12  556
14  11  560
9   7  563
13  10  565
12   9  571
15  11  577
11   8  579
14  10  583
10   7  588
13   9  591
15  10  600
14   9  609
11   7  611";

@list = split(/\n/,$string);

$i = 0;
foreach $l (@list) {
#print $l,"\n";
	($f,$r) = split(/\s+/,$l);
#print $f," ",$r," ",$p;
	$front[$i] = $f;
	$rear[$i] = $r;
	#$rat[$i] = $p;
	++$i;
}
#print "$i\n";

print "F";
for ( $j = 0; $j < $i; ++$j ) {
	printf("%3d",$front[$j]);
}
print "\n";
print "R";
for ( $j = 0; $j < $i; ++$j ) {
	printf("%3d",$rear[$j]);

}
print "\n";
