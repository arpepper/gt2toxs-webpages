#!/usr/bin/perl
$gt1string = '<font size="+1" color="blue">G</font><font size="+1" color="red">T</font><font size="+1">1</font>';
$gt2string = '<font size="+1" color="blue">G</font><font size="+1" color="red">T</font><font size="+1">2</font>';

sub genframe {
	my ($logname) = @_;
	my ($frames, $name, $titlename, $titlegtver);

	$titlegtver = $logname =~ /^gt2/ ? $gt2string : $gt1string;
	$frames = $logname;
	$frames = $logname . "-frames.html";
	$titlename = $logname . "-title.html";
	$name = $logname;
	$name =~ s/^gt2-//;
	if ( -f "$frames" ) {
		system("mv $frames .backup/");
	}
	if (!open(FRAMES,">$frames")) {
		die;
	}

	print FRAMES << "_EOF" ;
<HTML>
<HEAD>
<TITLE>Logs</TITLE>
</HEAD>
  <FRAMESET BORDER=2 ROWS="90,40,*,10%">
    <FRAME NAME="navigate" src="navigate.html" SCROLLING="auto">
    <FRAME NAME="title" src="$titlename" SCROLLING="auto">
    <FRAMESET BORDER=0 COLS="5%,90%,5%">
      <FRAME src="border.html">
      <FRAME NAME="log" src="$logname" SCROLLING="auto">
      <FRAME src="border.html">
    </FRAMESET>
    <FRAME NAME="navigate" src="navigate.html" SCROLLING="auto">
  </FRAMESET>

 <NOFRAME>
<p>
   <a href="$logname">$name</a>
</p>
 </NOFRAME>
</HTML>
_EOF
close(FRAMES);

	if ( -f "$titlename" ) {
		system("mv $titlename .backup/");
	}
	if (!open(TITLE,">$titlename")) {
		die;
	}

	print TITLE << "_EOF" ;
<html>
<head>
<meta name="robots" content="noindex,nofollow">
<body bgcolor="yellow">
</p>
$titlegtver log - $name

</body>
</html>
_EOF
close(TITLE);
}

while (defined($ARGV[0])) {
	&genframe($ARGV[0]);
	shift;
}
