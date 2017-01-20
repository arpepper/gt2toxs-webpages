#!/xhbin/perl5

$event = $ARGV[0];
shift;

#print "$event","\n";

$doing = 0;
if (!open(EVENTS,"<gt1events.txt") ) {
	die;
}
while (<EVENTS>) {
	if ($_ =~ /^${event}/ ) {
		$doing = 1;
		print << '_EOF' ;
<HTML INDENT>

<table border="0" cellpadding="0">
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td width="10%">&nbsp;</td></tr>
<tr><th align="left" colspan="3">
_EOF
		print $_;

		print << '_EOF' ;
</th></tr>
_EOF
		next;
	}
	if ($doing == 1) {   # general parameters
		if ($_ =~ /^\s*$/ ) {
			print "</table>\n\n</HTML>\n\n";
			$doing = 2;
			next;
		}
		$_ =~ s/^\s*//;
		$_ =~ s/\n//;
		($name, $addr) = split(" ",$_,2);
		print "<tr><td>&nbsp;</td><td>$name</td><td>&nbsp;$addr</td></tr>\n"
	}
	if ($doing == 2) {   # looking for start of tracks
		if ($_ =~ /^tracks$/) {
			print <<'_EOF' ;
<HTML INDENT>

<table border="0" cellpadding="0">
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td width="10%">&nbsp;</td><td width="20%">&nbsp;</td><td>&nbsp;</td></tr>
<tr><th align="left" colspan="5">
tracks
</th></tr>
_EOF
			$doing = 3;
			next;
		}
	}
	if ($doing == 3) {   # tracks address pointer
		$pointer = $_;
		$pointer =~ s/^\s*//;
		$pointer =~ s/\n$//;
		print "<tr><td>&nbsp;</td><td colspan=\"4\" align=\"left\">$pointer</td></tr>\n";
		$doing = 4;
		next;
	}
	if ($doing == 4) {   # tracks entries
		if ($_ =~ /^\s*$/ ) {
			print "</table>\n\n</HTML>\n\n";
			$doing = 5;
			next;
		}
		$_ =~ s/^\s*//;
		$_ =~ s/\n//;
		($addr, $short, $name) = split(" ",$_,3);
		print "<tr><td colspan=\"2\">&nbsp;</td><td>$addr</td><td>&nbsp;\"$short\"&nbsp;</td><td>$name</td></tr>\n";
	}
	if ($doing == 5) {   # looking for start of prizemoney
		if ($_ =~ /^prizemoney$/) {
			print <<'_EOF' ;
<HTML INDENT>

<table border="0" cellpadding="0" width="100%">
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td>&nbsp;</td></tr>
<tr><th align="left" colspan="3">
prizemoney
</th></tr>
_EOF
			$doing = 6;
			next;
		}
	}
	if ($doing == 6) {   # prizemoney address pointer
		$pointer = $_;
		$pointer =~ s/^\s*//;
		$pointer =~ s/\n$//;
		print "<tr><td>&nbsp;</td><td colspan=\"2\" align=\"left\">$pointer</td></tr>\n";
		$doing = 7;
		next;
	}
	if ($doing == 7) {   # prizemoney entry (for now)
		if ($_ =~ /^\s*$/ ) {
			print "</table>\n\n</HTML>\n\n";
			$doing = 8;
			next;
		}
		$stuff = $_;
		$stuff =~ s/^\s*//;
		$stuff =~ s/\n$//;
		print "<tr><td colspan=\"2\" width=\"10%\">&nbsp;</td><td>$stuff</td></tr>\n";
	}
	if ($doing == 8) {   # looking for start of entrants
		if ($_ =~ /^entrants$/) {
			print <<'_EOF' ;
<HTML INDENT>

<table border="0" cellpadding="0">
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td width="10%">&nbsp;</td><td width="20%">&nbsp;</td><td>&nbsp;</td></tr>
<tr><th align="left" colspan="5">
entrants
</th></tr>
_EOF
			$doing = 9;
			next;
		}
	}
	if ($doing == 9) {   # entrants address pointer
		$pointer = $_;
		$pointer =~ s/^\s*//;
		$pointer =~ s/\n$//;
		print "<tr><td>&nbsp;</td><td colspan=\"4\" align=\"left\">$pointer</td></tr>\n";
		$doing = 10;
		next;
	}
	if ($doing == 10) {   # entrants entries
		if ($_ =~ /^prize/ ) {
			# special for entrants, since we put blank lines in
			print "</table>\n\n</HTML>\n\n";
			$doing = 11;
			# no next, since we want to do this now
		}
		else {
			if ($_ =~ /^\s*$/ ) {
				# just print a blank line of table
				print <<_EOF ;
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td width="10%">&nbsp;</td><td width="20%">&nbsp;</td><td>&nbsp;</td></tr>
_EOF
				next;
			}
			$_ =~ s/^\s*//;
			$_ =~ s/\n//;
			($addr, $short, $name) = split(" ",$_,3);
			print "<tr><td colspan=\"2\">&nbsp;</td><td>$addr</td><td>&nbsp;\"$short\"&nbsp;</td><td>$name</td></tr>\n";
		}
	}
			
	if ($doing == 11) {   # looking for start of prizecars
		if ($_ =~ /^prizecars$/) {
			print <<'_EOF' ;
<HTML INDENT>

<table border="0" cellpadding="0">
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td width="10%">&nbsp;</td><td width="20%">&nbsp;</td><td>&nbsp;</td></tr>
<tr><th align="left" colspan="5">
prizecars
</th></tr>
_EOF
			$doing = 12;
			next;
		}
	}
	if ($doing == 12) {   # prizecars address pointer
		$pointer = $_;
		$pointer =~ s/^\s*//;
		$pointer =~ s/\n$//;
		print "<tr><td>&nbsp;</td><td colspan=\"4\" align=\"left\">$pointer</td></tr>\n";
		$doing = 13;
		next;
	}
	if ($doing == 13) {   # prizecars entries
		if ($_ =~ /^\s*$/ ) {
			print "</table>\n\n</HTML>\n\n";
			$doing = 14;
			next;
		}
		$_ =~ s/^\s*//;
		$_ =~ s/\n//;
		($addr, $short, $name) = split(" ",$_,3);
		print "<tr><td colspan=\"2\">&nbsp;</td><td>$addr</td><td>&nbsp;\"$short\"&nbsp;</td><td>$name</td></tr>\n";
	}

	if ($doing == 14) {   # looking for start of poletimes
		if ($_ =~ /^poletimes$/) {
			print <<'_EOF' ;
<HTML INDENT>

<table border="0" cellpadding="0">
<tr><td width="5%">&nbsp;</td><td width="5%">&nbsp;</td><td width="10%">&nbsp;</td><td width="20%">&nbsp;</td><td>&nbsp;</td></tr>
<tr><th align="left" colspan="5">
poletimes
</th></tr>
_EOF
			$doing = 15;
			next;
		}
	}
	if ($doing == 15) {   # poletimes address pointer
		$pointer = $_;
		$pointer =~ s/^\s*//;
		$pointer =~ s/\n$//;
		print "<tr><td>&nbsp;</td><td colspan=\"4\" align=\"left\">$pointer</td></tr>\n";
		$doing = 16;
		next;
	}
	if ($doing == 16) {   # poletimes entries
		if ($_ =~ /^\s*$/ ) {
			print "</table>\n\n</HTML>\n\n";
			$doing = 0;
			next;
		}
		$_ =~ s/^\s*//;
		$_ =~ s/\n//;
		($addr, $short, $name) = split(" ",$_,3);
		print "<tr><td colspan=\"2\">&nbsp;</td><td>$addr</td><td>&nbsp;$short&nbsp;</td><td>$name</td></tr>\n";
	}
}
