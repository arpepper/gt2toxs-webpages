#!/xhbin/perl5

sub
display {
	local ($hunk,$hint) = @_;
	local $type;

	if ($hint eq "literal") {
		print $hunk;
		return;
	}
	if ($hunk eq "" || $hunk eq "\n") {
		return;
	}
	$type = &identify($hunk,$hint);
	$hunk = &transform($hunk,$type);
	$hunk = &process($hunk,$type);
	print $hunk;


}

sub
inthread {
	local ($thread,$filename) = @_;
	local ($string);

	$string = $threadlist{$thread};
	return $string =~ /^${filename}$/m || $string =~ /^${filename}:/m;
}

sub
addthread {
	local ($thread,$filename) = @_;

	$thread =~ s/\n//g;
	$thread =~ s/^\s*//;
	$thread =~ s/\s*$//;
	if (defined($threadlist{$thread})) {
		if ( !inthread($thread,$filename)) {
			$threadlist{$thread} .= "$filename" . "\n";
		}
		elsif ( $threadlist{$thread} !~ /:i\n$/ ) {
# Assert: filename will always be the last one in matched thread
			$threadlist{$thread} =~ s/\n$/:i\n/;
		}
		else {
			$threadlist{$thread} =~ s/\n$/i\n/;
		}
	}
	else {   # extras i's indicate a minor problem
		$threadlist{$thread} = "$filename" . "\n";
	}
}



$myplace = ".";
#print $me,"\n",$myplace,"\n";

$names = `cd $myplace; ls *-*-*.txt`;
@namelist = split(/\n/,$names);
$prevpage = "";
$nextpage = "";
$index = "index.html";

for ( $i = 0; $i <= $#namelist; ++$i) {
#print $namelist[$i],"\n";
	$name = $namelist[$i];
#print $name,"\n";
	if (!open(FILE,"<$name")) {
		die "Cannot open $name";
	}
	$tstate = 0;
	while (<FILE> ) {
#print $_;
		if ( $_ =~ /^Threads{0,1}:/) {
#print "Found thread in $name\n";
			if ( $_ =~ /:\s*\S/ ) {
				$thread = $_;
				$thread =~ s/^[^:]*://;
				if (!defined($threadlist{$thread})) {
					# force a ":i" for single-line entry
					&addthread($thread,$name);
				}
				&addthread($thread,$name);
			}
			$tstate = 1;
		}
		elsif ($tstate == 1) {
			if ($_ =~ /^\s*$/ ) {
				$tstate = 2;
			}
			else {
				&addthread($_,$name);
			}
		}
	}
	close(FILE);
}

foreach $thread (sort keys %threadlist) {
	print "$thread","\n",$threadlist{$thread},"\n";
}
