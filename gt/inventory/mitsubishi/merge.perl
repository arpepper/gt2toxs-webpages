#!/xhbin/perl5 -w
if (!defined(open(NEWH,"<./newheaders")) ) {
	die "Cannot open ./newheaders";
}
if (!defined(open(OLD,"<./total")) ) {
	die "Cannot open ./total";
}
else {
	$oldopen = 1;
}
mainloop:
while ( <NEWH> ) {
	$line = $_;
	while (  $line =~ /^$/ ) {
		if (!defined($line = <NEWH>)) {
			last mainloop;
		}
	}
	$full = $line;
	$part = substr($line,0,34);
	$oldopen = 0;
innerloop:
	while (<OLD>) {
		print;
		if ($part eq substr($_,0,34)) {
			print $full;
			$oldopen = 1;
			last innerloop;
		}
	}

}
if ($oldopen) {
	while (<OLD>) {
		print;
	}
}
else {
	warn "end of old input reached before end of headers\n";
}

