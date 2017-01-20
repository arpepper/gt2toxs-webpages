#!/usr/bin/perl

$pat = shift;

$buf = "";
$printit = 0;
while (<>) {
	if ($_ =~ /^\s*$/) {
		if ($buf && $printit) {
			print $buf;
			print $_;
		}
		$buf = "";
		$printit = 0;
	}
	else {
		if ($_ =~ /$pat/) {
			$printit = 1;
		}
		$buf .= $_;
	}
}

if ($buf && $printit) {
	print $buf;
	print $_;
}
$buf = "";
$printit = 0;
