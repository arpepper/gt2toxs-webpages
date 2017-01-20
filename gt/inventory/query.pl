#!/xhbin/perl5 -w
#
# Read commands as standard input
#
# url=<URL>   usu. file:
# augment  - process query so far, then begin new one to "or" in
#            i.e. query data from file, add to selected set
# restrict - process query so far, then begin new one to "and" in
#            i.e. apply new query to selected set only
# exclude  - process query so far, then begin new one to remove
#            i.e. apply negative of new query to selected set
#
# select(expr) - add expr to "and" list for current query
#     expr   expr = expr
#            expr < expr
#            expr > expr
#            field
#            value
# sortby(exprlist) - sort current selection according to expr
#     expr   field
#
# output(fieldlist)

# logically we could keep result as a string, but there aren't
#  really efficient ways of walking through large strings

sub
do_url {
	local($url) = @_;
	local($fname, $contents);

	$contents = "";
	$url =~ s/^ *//;
	if ( $url =~ /^file:/i ) {
		$fname = $url;
		$fname =~ s/file://i;
		if (defined(open(URL,"<$fname"))) {
			while (<URL>) {
				$contents .= $_;
			}
			close(URL);
		}
	}
	return $contents;
}

sub
add_select {
	local($expr) = @_;

	# add expression to (encoded) list of things to do
}

sub
query {
	local($set) = @_;

	

	return $set;
}

sub
minus {
	local($set,$exclusion) = @_;

	return $set;
}

sub
sortby {
	local($set,$sortrules) = @_;

	return $set;
}

sub
output {
	local($set) = @_;

	print $set;
}




$url_contents = "";

$selection = "";
while (<>) {
	$line = $_;
	$line =~ s/\n//;
	$cmd = "";
	$remainder = "";
	$line =~ /([^ (]*)/;
	$cmd = $1 if defined($1);
	$line =~ /([^ (]*)([ (].*)/;
	$remainder = $2 if defined($2);
	if ($cmd eq "select") {
		&add_select($remainder);
	}
	elsif ($cmd eq "augment") {
		$selection .= &query($url_contents);
	}
	elsif ($cmd eq "restrict") {
		$selection = &query($selection);
	}
	elsif ($cmd eq "exclude") {
		$exclusion = &query($url_contents);
		$selection = &minus($selection,$exclusion);
	}
	elsif ($cmd eq "sortby") {
		$selection = &sortby($selection,$remainder);
	}
	elsif ($cmd eq "output") {
		&output($selection,$remainder);
	}
	elsif ($cmd eq "url") {
		$url_contents = &do_url($remainder);
	}
	
}
