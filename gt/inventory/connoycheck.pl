#!/xhbin/perl5 -w
if (!open(CONNOY,"<connoydata")) {
	die "Cannot open connoydata\n";
}
$mfcr = "";
while (<>) {
	if ($_ =~ /^ [^ ]./) {
		$name = $_;
		$name =~ s/\n//;
		$name =~ s/  .*//;
		$name =~ s/^ //;
		@list = (@list,$_);
		$lookup{$name} = $_;
		$iname = $name;
		$iname =~ s/[. ]//g;
		$iname =~ s/-//g;
		$iname = lc($iname);
#print "iname=$iname\n";
		$suggested{$iname} = $name;
	}
	else {
		#print $_;
		if ($_ =~ /^[^ ]/) {
			$mfcr = $_;
			$mfcr =~ s/\n//;
			$mfcr =~ s/ .*//;
		}
	}
}

$mfcr = "";
while (<CONNOY>) {
	if ($_ =~ /\(.* entries.*\)/ ) {
		$mfcr = $_;
		$mfcr =~ s/\n//;
		$mfcr =~ s/ .*//;
	}
	elsif ( $_ =~ /^Name {30}Drv/ ) {
		;
	}
	elsif ( $_ =~ /./ && $_ !~ /^===/ && $_ !~ /^----/) {
		$name = $_;
		$name =~ s/\n//;
		if ( $name =~ /(.{34})(.*)/ ) {
			$name = $1;
			$name =~ s/ *$//;
			@list = (@list,$_);
			if (defined($lookup{$name}) ) {
				;
			}
			else {
				$iname = $name;
				$iname =~ s/[ .]//g;
				$iname =~ s/-//g;
				$iname = lc($iname);
#print "iname=$iname\n";
				$sug = "";
				if (defined($suggested{$iname}) ) {
					$sug = " -- perhaps $suggested{$iname}";
				}
				print "-->",$name,$sug,"\n";
			}
		}
		else {
			print "*** unexpected $name\n";
		}
	}
}
close(CONNOY);
