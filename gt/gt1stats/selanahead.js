// Copyright (c) 2001 Adrian Pepper, all rights reserved.
// Contact arpepper at math.uwaterloo.ca  for more information.

function
mkhead() { // custom routine to make header for page
	var head;

	head = '<table width="100%" bgcolor="black">\n';
	head += '<tr color="white">\n';
	head += '<td>\n';
	head += '<font color="white">\n';
	head += '<h3><img src="../../gifs/gtlogo.jpg" alt="Gran Turismo"> Car Finder</h3>\n';
	head += '</font>\n';
	head += '</td>\n';
	head += '</tr>\n';
	head += '</table>\n';

	head += '<table width="85%"><tr><td width="5%"></td><td>\n';
	head += '<center>\n';
	head += '<table><tr><td bgcolor="cyan">\n';
	head += '<font size="-2">\n';
	head += '[<a href="index.html">Tutorial</a>]\n';
	head += '[<a href="../../gt/">Gran Turismo pages</a>]\n';
	head += '[<a href="../../gt/gt1stats/">car find</a>]\n';
	head += '[<a href="../../gt/gt1used/">used cars</a>]\n';
	head += '[<a href="../../gt/diary/">diary</a>]\n';
	head += '</font>\n';
	head += '</td></tr></table>\n';
	head += '</center>\n';
	head += '</td></tr></table>\n';
	head += '<p>\n';
	head += '<font size="-2">\n';
	head += 'To contact the author by\n';
	head += '<a href="../email.html">email</a>.\n';
	head += '</font>\n';
	head += '</p>\n';

	return head;
}

document.writeln(mkhead());
