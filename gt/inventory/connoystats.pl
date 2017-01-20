#!/xhbin/perl5 -w

sub
fill1 {
	local($field) = @_;

	if ($field eq "") {
		return $field;
	}
	elsif ($field =~ /[^ ]/) {
		return $field;
	}
	else {
		$field =~ s/  / -/;
		return $field;
	}
}
#
#
# Griffith 4.0                      FR  5 327   430   2336  1820  1565   Great
# *[R]Cerbera LM Edition            FR  6       581               1984   Great
# 1234567890123456789012345678901234567890123456789012345678901234567890123456
#          1         2         3         4         5         6         7      
#                                   123456789012345678901234567890123456789012
#                                            1         2         3         4
#
#
sub
fillfields {
	local($info) = @_;

	if ($info =~ /^(.{3}) (.) (.{5}) (.{5}) (.{5}) (.{5}) (.{4,5})(.{0,7})$/) {
		$drive = &fill1($1);
		$ngears = &fill1($2);
		$stockhp = &fill1($3);
		$maxhp = &fill1($4);
		$stockwt = &fill1($5);
		$tunedwt = &fill1($6);
		$racewt = &fill1($7);
		$rating = &fill1($8);
		return "$drive $ngears $stockhp $maxhp $stockwt $tunedwt $racewt$rating";
	}
	else {
		print "*** Bad info $info\n";
		return $info;
	}
}

if (!open(CONNOY,"<connoydata")) {
	die "Cannot open connoydata\n";
}
$mfcr = "";
while (<CONNOY>) {
	if ($_ =~ /\(.* entries.*\)/ ) {
		$mfcr = $_;
		$mfcr =~ s/\n//;
		$mfcr =~ s/ .*//;
	}
	elsif ( $_ =~ /./ && $_ !~ /^===/ && $_ !~ /^----/ && $_ !~ /^Name {30}/ ) {
		$name = $_;
		$name =~ s/\n//;
		if ( $name =~ /(.{34})(.*)/ ) {
			$name = $1;
			$data = $2;
			$data = &fillfields($data);
			$name =~ s/( *)$//;
			$data = "$1$data";
			@list = (@list,$_);
			$lookup{$name} = $data;
			$iname = $name;
			$iname =~ s/[. ]//g;
			$iname =~ s/-//g;
			$iname = lc($iname);
#print "iname=$iname\n";
			$suggested{$iname} = $name;
		}
		else {
			print "*** unexpected $name\n";
		}
	}
}
close(CONNOY);

$mfcr = "";
while ( <> ) {
	if ($_ =~ /^ [^ ]./) {
		$name = $_;
		$name =~ s/\n//;
		$name =~ s/  .*//;
		$name =~ s/^ //;
		if (defined($lookup{$name}) ) {
			print " $name $lookup{$name}\n";
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
			print "***",$name,$sug,"\n";
		}
	}
	else {
		print $_;
		if ($_ =~ /^[^ ]/) {
			$mfcr = $_;
			$mfcr =~ s/\n//;
			$mfcr =~ s/ .*//;
		}
	}
	
}
