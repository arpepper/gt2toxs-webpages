#!/xhbin/perl5

while (<>) {
	push @lines, $_;
	if ($_ =~ /^(....)n *(.*)/) {
		$key = $1;
		$n = $2;
		$name{$key} = $n;
	}
}

$addr = 0x80053AFC;
foreach (@lines) {
	if ($_ =~ /^....n *(.*)/) {
		printf("%X   %s", $addr, $_);
	}
	elsif ($_ = /^(....)r/) {
		$key = $1;
		printf("%X   %s\n", $addr, $key . "r   " . "[R]" . $name{$key});
	}
	else {
		print "Bad line: $_";
	}
	$addr += 8;
}
