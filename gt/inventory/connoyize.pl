#!/usr/bin/perl -w
if (!open(CONNOY,"<connoydata")) {
	die "Cannot open connoydata\n";
}
$mfcr = "";
while (<CONNOY>) {
	if ($_ =~ /\(.* entries,.*distinct\)/ ) {
		$mfcr = $_;
		$mfcr =~ s/\n//;
		$mfcr =~ s/ .*//;
	}
	elsif ( $_ =~ /./ && $_ !~ /^===/ && $_ !~ /^----/) {
		$name = $_;
		$name =~ s/\n//;
		$name =~ s/(.{34}).*/$1/;
		$name =~ s/ *$//;
		@list = (@list,$_);
		$lookup{$name} = $mfcr;
		$iname = $name;
		$iname =~ s/[. ]//g;
		$iname =~ s/-//g;
		$iname = lc($iname);
#print "iname=$iname\n";
		$suggested{$iname} = $name;
	}
}

$mfcr = "";
while ( <> ) {
	if ($_ =~ /^ [^ ]./) {
		$name = $_;
		$name =~ s/\n//;
		$name =~ s/  .*//;
		$name =~ s/^ //;
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
			print $name,$sug,"\n";
		}
	}
	elsif ($_ =~ /^[^ ]/) {
		$mfcr = $_;
		$mfcr =~ s/\n//;
		$mfcr =~ s/ .*//;
	}
	
}
