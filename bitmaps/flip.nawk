function convert(string, hex, value, v1, mask, fmask) {
	hex = "0123456789abcdef";
	v1 = index(hex, substr(string, 3, 1))-1 ;
	value = v1;
	value *= 16;
	v1 = index(hex, substr(string, 4, 1))-1 ;
	value += v1;
	v1 = value;
	value = 0;
	fmask = 1;
	for (mask = 128; mask > 0; mask /= 2) {
		if (v1 >= mask) {
			value += fmask;
			v1 -= mask;
		}
		fmask *= 2;
	}
	return value;
}

{
	if ( $0 !~ /0x.., 0x.., 0x.., 0x..,/ ) {
		print
	}
	else {
		printf("\t");
		for (i = 1; i <= NF; ++i ) {
			x = convert( $i );
			printf(" 0x%2.2x,", x);
		}
		printf("\n");
	}
}
