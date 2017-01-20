// Copyright (c) 2001 Adrian Pepper, all rights reserved.
// Contact arpepper at math.uwaterloo.ca  for more information.
//
Stat("Initializing");

//
// 99 - magic column number means "sequence number" (line number of output)
// 98 - magic column number means "repeat count" (number shown as one)
//
var supcolnames = new Array(); 
supcolnames[0] = "Sequence"; 
supcolnames = supcolnames.concat(colnames, "Count");
supcolnums = new Array(99, 0);  // duh!  single arg is length...
for (i = 0; i < colnames.length; ++i) {
	supcolnums[i+1] = i;
}
supcolnums[i+1] = 98;


var opnames = new Array("Contains", "Less Than", "Equal", "Greater");
var opcodes = new Array("::", "<", "=", ">");

var conjnames = new Array("and", "or", "BIGAND", "BIGOR");
var conjcodes = new Array("and", "or", "bigand", "bigor");

var OP_MAT = 1;    // ::
var OP_IN = 2;     // :=
var OP_LE = 3;     // <=
var OP_LT = 4;     // <
var OP_EQ = 5;     // ==
var OP_GT = 6;     // >
var OP_GE = 7;     // >=
var OP_AND    = 20;   // and
var OP_OR     = 21;   // or
var OP_BIGAND = 22;   // bigand
var OP_BIGOR  = 23;   // bigor

function token_op( operator ) {

	if ( operator == "::" ) {
		return OP_MAT;
	}
	if ( operator == ":=" ) {
		return OP_IN;
	}
	if ( operator == "<" ) {
		return OP_LT;
	}
	if ( operator == "<=" ) {
		return OP_LE;
	}
	if ( operator == "=" ) {
		return OP_EQ;
	}
	if ( operator == "==" ) {
		return OP_EQ;
	}
	if ( operator == ">=" ) {
		return OP_GE;
	}
	if ( operator == ">" ) {
		return OP_GT;
	}
	if ( operator == "and" ) {
		return OP_AND;
	}
	if ( operator == "or" ) {
		return OP_OR;
	}
	if ( operator == "bigand" ) {
		return OP_BIGAND;
	}
	if ( operator == "bigor" ) {
		return OP_BIGOR;
	}
	return 0;
}

function Matcher( field, not, op, value, conj ) {
	var num;

	this.field = field;
	this.not = not;
	this.op = token_op(op);

	this.pat = new RegExp( value , "");
	this.pati = new RegExp( value , "i");
	this.value = value;
	num = value;
	num = num.replace( /[^0-9.]/g, "");
	num = num.replace( /([.][^.]*)[.].*/, "$1" );
	this.num = num - 0;
	this.numeric = (this.value == this.num);

	this.conj = token_op(conj);

	Dbg(this.field + " " + this.not + " " +
					this.op + " " + this.pat + " " +
					this.pati + " " + this.value + " " +
					this.num + " " + this.numeric + " " +
					this.conj + "\n");
}

function mkSel(name,strings,offset,values,selected,selstr) {
	var i;
	var optstring;
	var optvalue;
	var s;

	s = "";
	s += "<select name=\"" + name + "\">\n";
	i=0;
	while (strings[i] != null) {
		optstring = strings[i];
		optvalue = i + offset;
		if (optstring[i] == "") {
			optstring = "Field " + optvalue;
		}
		if (values[i] != null) {
			optvalue = values[i];
		}
		s += "<option value=\"" + optvalue + "\"";
		if (selstr != null) {
			if (selstr == optvalue) s += " selected";
		}
		else {
			if (selected == i) s += " selected";
		}
		s += ">" + optstring + "</option>\n";
		i++;
	}
	s += "</select>\n";
	return s;
}

function
mkText(name,value,width) {
	return "<input type=\"text\" name=\""+name+"\" value=\""+value+"\" size="+width+">";
}


function mkMul(name,strings,offset,values,size,selvalues) {
	var i,si;
	var optstring;
	var optvalue;
	var s, sel;

	s = "";
	s += "<select name=\"" + name + "\" multiple";
	if (size != 0) {
		s += " size=\"" + size + "\"";
	}
	s += ">\n";
	i=0;
	si=0;
	while (strings[i] != null) {
		optstring = strings[i];
		optvalue = i + offset;
		if (optstring[i] == "") {
			optstring = "Field " + optvalue;
		}
		if (values[i] != null) {
			optvalue = values[i];
		}
		sel = "";
		if (selvalues != null && optvalue == selvalues[si]) {
			// selvalues must be sorted
			sel = " selected";
			si++;
		}
		s += "<option value=\"" + optvalue + "\"" + sel + ">" + optstring + "</option>\n";
		i++;
	}
	s += "</select>\n";
	Dbg(s);
	return s;
}


function first_line (s) {  // return first line of given buffer
	var match_line = /.*[\r\n]+/;
	var result = s.match(match_line);
	if (result != null) {
		return result[0];
	}
	return s;
}
function remove_line (s) {  // remove first line of given buffer
	var match_line = /.*[\r\n]+/;
	var result = s.match(match_line);
	if (result != null) {
		var s1 = s;
		s1 = s1.replace(match_line,"");
		return s1;
	}
	return "";
}

var cmp_limit = 1000;
var cmp_incr = 1000;
var cmp_count = 0;
var bug_limit = 0;
function
cmp_recs(a, b) {
	var cmpres, f, fn, str1, str2, num1, num2;

	if (++cmp_count >= cmp_limit) {
		if (more_query) {
			document.stat.stat.value += ".";
			if (document.stat.stat.value.length >= 44) {
				document.stat.stat.value =
					 document.stat.stat.replace(/\./g,"");
			}
		}
		cmp_count = 0;
		cmp_limit += cmp_incr;
	}
	cmpres = 0;
	for (f = 0; (fn = sort_keys[f]) != null ; ++f) {
		str1 = a[fn];
		str2 = b[fn];
		// following should not happen; we had a bug
		if (str1 == null || str2 == null) {
			// we might as well leave this check in...
			if (++bug_limit <= 20) Dbg("Bad sort key [" + f + "] = |" + fn + "| " + typeof(fn) + "\n");
			return 0;
		}
		if ( !str1.match(/[^.\d]/) && !str2.match(/[^.\d]/) ) {
			num1 = str1 - 0;
			num2 = str2 - 0;
			if (num1 < num2 ) {
				cmpres = -1;
			}
			else if (num1 > num2) {
				cmpres = 1;
			}
		}
		else {
			if (str1 < str2 ) {
				cmpres = -1;
			}
			else if (str1 > str2) {
				cmpres = 1;
			}
		}
		if (cmpres != 0) {
			if (sort_rev[f]) {
				cmpres = -cmpres;
			}
			return cmpres;
		}
	}
	return 0;
}

function
initOutput() {
	lines = new Array();
	linei = 0;
	line_count = 0;
	match_count = 0;
	prev_oline = "";
	if (output_type == "HTML") {
		lines[linei++] = mkHdr();
	}
}

function
flushOutput(oline) {
	var v;
	var border;

	border = no_border ? "border=0" : "bgcolor=\"white\" border";
	if (line_count < line_limit) {
		if (prev_oline != "") {
			++line_count;
			v = prev_oline;
			v = v.replace(/%%%LC%%%/g, line_count);
			v = v.replace(/%%%MC%%%/g, match_count);
			if ( output_type == "HTML") {
				// The following could be very expensive...
				v = v.replace(/[,]([.\d]+)\b/g, "</td><td align=right>$1");
				v = v.replace(/[,](-)/g, "</td><td align=center>$1");
				v = v.replace(/[,]/g, "</td><td>");
				v = v.replace(/^([.\d]+)\b/g, "<td align=right>$1");
				v = v.replace(/^(-)/g, "<td align=center>$1");
				v = v.replace(/^[^<]/g, "<td>$&");
				v = "<tr>" + v + "</td></tr>\n";
			}
			else if ( output_type == "BRIEF" ) {
				v = v.replace(/[,]([.\d]+)\b/g, "</td></tr>\n<tr><td align=left>$1");
				v = v.replace(/[,](-)/g, "</td></tr>\n<tr><td align=center>$1");
				v = v.replace(/[,]/g, "</td></tr>\n<tr><td>");
				v = v.replace(/^([.\d]+)\b/g, "<tr><td align=left>$1");
				v = v.replace(/^(-)/g, "<tr><td align=center>$1");
				v = v.replace(/^[^<]/g, "<tr><td>$&");
				v = "<table width=100% " + border + ">" + v + "</td></tr></table><BR>\n";
			}
			else if ( output_type == "LABELED" ) {
				v = addHdr(v);
				v = "<table width=100% " + border + ">" + v + "</td></tr></table><BR>\n";
			}
			else {
				v = v + "\n";
			}
		}
		lines[linei++] = v;
	}
	// connive to allow mkOutput to count non-printed lines
	prev_oline = oline;
	statCount(line_count,number_found,number_unique);
	++number_unique;
}

function
mkOutput(record) {
	var f, fn, oline, i, str;

	oline = "";
	for ( f = 0; (fn = sel_fields[f]) != null ; ++f) {
		str = "";
		if (fn == 99) {
			// Do this, or we'd force all lines out
			str = '%%%LC%%%';
		}
		else if (fn == 98) {
			str = '%%%MC%%%';
		}
		else {
			str = record[fn];
		}
		oline += "," + str;
	}
	oline = oline.replace(/^,/,"");
	if (oline != prev_oline) {
		flushOutput(oline);
		match_count = 1;
	}
	else {
		++match_count;
	}
}


function
isMatch(a, matcher) {
	var field, not, nfield;

	field = a[matcher.field];
	not = matcher.not;
	if ( matcher.op == OP_MAT ) {
		return not ^ (field.match( matcher.pati ) != null);
	}
	else if ( matcher.op == OP_IN ) {
		return not ^ (field.match( matcher.pat ) != null);
	}
	else {
		nfield = field;
		if ( matcher.numeric ) {
			nfield = nfield.replace( /[^0-9.]/g, "");
			nfield = nfield.replace( /([.][^.]*)[.].*/, "$1" );
			if (nfield == "") {
				nfield = 0;
			}
			nfield = nfield - 0; // force to numeric
		}
		// should find cheaper way to remember following
		if ( matcher.numeric  &&
				( nfield == field || field == "-") ) {
			// numeric comparison suitable
			if ( matcher.op == OP_LT ) {
				return not ^ (nfield < matcher.num);
			}
			else if ( matcher.op == OP_LE ) {
				return not ^ (nfield <= matcher.num);
			}
			else if ( matcher.op == OP_EQ ) {
				return not ^ (nfield == matcher.num);
			}
			else if ( matcher.op == OP_GE ) {
				return not ^ (nfield >= matcher.num);
			}
			else if ( matcher.op == OP_GT ) {
				return not ^ (nfield > matcher.num);
			}
			else {
			}
		}
		else {
			if ( matcher.op == OP_LT ) {
				return not ^ (field < matcher.value);
			}
			else if ( matcher.op == OP_LE ) {
				return not ^ (field <= matcher.value);
			}
			else if ( matcher.op == OP_EQ ) {
				return not ^ (field == matcher.value);
			}
			else if ( matcher.op == OP_GE ) {
				return not ^ (field >= matcher.value);
			}
			else if ( matcher.op == OP_GT ) {
				return not ^ (field > matcher.value);
			}
			else {
			}
		}
	}

	return 0;   // should not happen
}

function try1match(a, matchera, start ) {
        var i;
        var mode, match, submatch;

	match = -1;   // -1 - not set ;  1 - true ;  0 - false
	mode = OP_AND;
	for (i = start; matchera[i] != null; ++i ) {
		submatch = isMatch(a, matchera[i]);
		if ( mode == OP_AND) {
			if ( match != 0) {
				match = submatch;
			}
		}
		else if ( mode == OP_OR) {
			if ( submatch > match) {
				match = submatch;
			}
		}
		else if ( mode == OP_BIGAND) {
			if ( match == 0) break;
			match = submatch;
		}
		else if ( mode == OP_BIGOR) {
			if ( match == 1) break;
			match = submatch;
		}
		mode = matchera[i].conj;
	}
	return (match > 0);
}

function find1search ( matchera ) {  // do a search
	var found = new Array();
	var fi = 0;
        var i;

	for (i = 0; cardata[i] != null; ++i) {
		if (try1match(cardata[i], matchera, 0 ) ) {
			found[fi] = cardata[i];
			fi++;
		}
	}
	Dbg("\nfind1: " + fi + "\n");
	return found;
}

function selvalue ( sel ) {   // get selected value out of an options list
	if (sel == null) {
		// happens most often for undefined conjunction...
		return 0;
	}
	return sel.options[sel.selectedIndex].value;
}

function mulvalue ( sel ) {   // get selected values out of a multiple list
	var a = new Array();
	var si, si2, ai;


	if (sel == null) {
		return a;
	}
	ai = 0;
	if (sel[0].options != null) {
		for (si = 0; sel[si] != null && sel[si].options != null; ++si) {
			for (si2 = 0; sel[si].options[si2] != null; ++si2) {
				if (sel[si].options[si2].selected) {
					a[ai++] = sel[si].options[si2].value;
				}
			}
		}
	}
	else if (sel.options != null) {
		for (si = 0; sel.options[si] != null; ++si) {
			if (sel.options[si].selected) {
				a[ai++] = sel.options[si].value;
			}
		}
	}
	return a;
}

function buildSearch(parms) {
	var s = new Array();
	var si;

	Dbg("buildSearch:");
	si = 0;
	while (parms.values[si] != null && 
			parms.values[si] != "" && si < 20) {
		Dbg(" " + si + ": " +
			parms.queries[si] + " " +
			parms.nots[si] + " " +
			parms.ops[si] +  " " +
			parms.values[si] + " " +
			parms.conjs[si] + "\n");
		s[si] = new Matcher(
			parms.queries[si],
			parms.nots[si],
			parms.ops[si],
			parms.values[si],
			parms.conjs[si]
			);
		si++;
	}
	return s;
}

function buildDocSearch() {
	var s = new Array();
	var si;

	si = 0;
	while (document.find.v[si] != null && 
			document.find.v[si].value != null &&
			document.find.v[si].value != "" && si < 20) {
		Dbg( " " + si + ": " +
			selvalue(document.find.q[si]) + " " +
			selvalue(document.find.n[si]) + " " +
			selvalue(document.find.op[si]) +  " " +
			document.find.v[si].value + " " +
			selvalue(document.find.t[si]) + "\n");
		s[si] = new Matcher(
			selvalue(document.find.q[si]),
			selvalue(document.find.n[si]),
			selvalue(document.find.op[si]), 
			document.find.v[si].value, 
			selvalue(document.find.t[si])
			);
		si++;
	}
	return s;
}

function
mkHdr() {
	var oline, f, fn;

	oline = ""
	if ( output_type == "HTML") {
		oline += "<tr>";
		for ( f = 0; (fn = sel_fields[f]) != null; ++f) {
			if (fn < 90) {
				oline += "<th>" + fieldnames[fn] + "</th>";
			}
			else if (fn == 98) {
				oline += "<th>Count</th>";
			}
			else {
				oline += "<th>&nbsp;</th>";
			}
		}
		oline += "</tr>\n";
	}
	return oline;
}

function
addHdr(s) {  // adds headings to every line (LABELED output)
	var oline, f, fn, fv, fname;

	fv = s;
	oline = ""
	
	for ( f = 0; (fn = sel_fields[f]) != null; ++f) {
		oline += "<tr>";
		if (fn < 90) {
			fname = fieldnames[fn];
			if (fname == null || fname == "" ||
					 fname == "&nbsp;" ) {
				fname = colnames[fn];
			}
			oline += "<th align=\"left\" width=\"1\">" + fname + "</th>";
		}
		else if (fn == 98) {
			oline += "<th align=\"left\">Count</th>";
		}
		else {
			oline += "<th align=\"left\">&nbsp;</th>";
		}
		oline += "<td width=\"70%\">";
		oline += fv.replace(/,.*/, "");
		oline += "</td></tr>\n";
		fv = fv.replace(/^[^,]*,/, "");
	}
	oline += "</tr>\n";
	return oline;
}

function
contains(array, value) {  // test if array contains value
// shouldn't this be defined in the standard?
// should I add this as a method to Array()?  ie. array.contains(value) ?
	var i;
	for (i = 0; array[i] != null; ++i) {
		if (array[i] == value) return true;
	}
	return false;
}

function
extend_sort() {   // arrange to always sort forwards by selection fields
	var i, field;

	Dbg("sort:" + sort_keys.join(" ") + "\n");
	for (i = 0; (field = sel_fields[i]) != null; ++i ) {
		// fields greater than 90 only appear after the sort
		if (field < 90) {
			if (!contains(sort_keys,field)) {
				sort_keys.push(field);
				sort_rev.push(0);
			}
		}
	}
	Dbg("now sort:" + sort_keys.join(" ") + "\n");
}

function
findParms(searcha) {   // do a search with searcha parameters, also externals
	var new_out_search = "";
	var found, i;

	if (output_type == "HTML") {
		new_out_search += "<table ";
		new_out_search += no_border ?
				"border=0" : "bgcolor=\"white\" border";
		new_out_search += ">\n";
	}
	else if (output_type == "BRIEF" || output_type == "LABELED") {
		new_out_search += "<table><tr><td>\n";
	}
	extend_sort();
	Stat("Searching");
	found = find1search(searcha);
	number_found = found.length;
	number_unique = 0;
	Stat("Sorting " + number_found);
	if (sort_keys.length > 0)
		found.sort(cmp_recs);
	initOutput();
	// Joining each found into lines[], then joining lines[] into a string
	// works much better than successive string += each joined line.
	// The latter uses excessive memory, either because of a leak, or
	// perhaps just because of fragmentation.
	for ( i = 0; found[i] != null; ++i) {
		mkOutput(found[i]);
	}
	flushOutput("");
	if (output_type == "HTML") {
		new_out_search += lines.join("") + "</table>\n";
	}
	else if (output_type == "BRIEF" || output_type == "LABELED") {
		new_out_search += lines.join("") + "</td></tr></table>\n";
	}
	else {
		new_out_search += lines.join("");
	}

	return new_out_search;
}

function
statCount(shown,total,unique) {
	Stat("Displaying " + shown + " of " + total + " Results (" + unique + " unique)");
}

function
showResults(result) {
	var ttype = output_type;
	var tqf = quick_find;
	var n = (number_found > line_limit) ? line_limit : number_found;

	if (output_dest == "text") {
		document.output.out_search.value = result;
	}
	else {
		if (tqf) {
			var head = mkhead();
			// following wipes out many vars and functions
			document.write("<HTML><HEAD></HEAD><BODY BGCOLOR=\"yellow\">\n");
			document.write(head);
			document.writeln('<hr>');
		}
		if (ttype == "lotus") document.write("<PRE>\n");
		document.write(result);
		if (ttype == "lotus") document.write("</PRE>\n");
		document.write("<BR><HR><BR>\n");
		if (tqf) {
			document.write("</BODY></HTML>\n");
		}
	}
}

var quick_find = 0;
function dofind() {
	var i;

	quick_find = 1;
	// show_debug = 0;  // global

	if (qArgs != null) {
		Dbg(qArgs.toString());
		Dbg("\n");
	}

	line_limit = document.find.ls.value - 0;
	Dbg("line_limit=" + line_limit + "\n");
	line_limit = line_limit - 0;
	if (line_limit <= 0 || line_limit == NaN) {
		line_limit = 65535;
	}
	Dbg("line_limit=" + line_limit + "\n");
	sort_keys = mulvalue(document.find.s);
	sel_fields = mulvalue(document.find.f);
	for (i=0; i < sort_keys.length; ++i) {
		sort_rev[i] = false;
	}
	if (selvalue(document.find.sr) > 0) {
		for (i=0; i < sort_keys.length; ++i) {
			sort_rev[i] = true;
		}
	}
	output_type = selvalue(document.find.ot);
	output_dest = selvalue(document.find.od);
	no_border = selvalue(document.find.nb) > 0;
	search_parms = buildDocSearch();
	search_result = findParms(search_parms);
	search_done = 1;
	showResults(search_result);
}

function doquery(parms) {
	var i;

	// show_debug = 0;  // global

	if (qArgs != null) {
		Dbg(qArgs.toString());
		Dbg("\n");
	}

	line_limit = parms.line_limit - 0;
	Dbg("line_limit=" + line_limit + "\n");
	line_limit = line_limit - 0;
	if (line_limit <= 0 || line_limit == NaN) {
		line_limit = 65535;
	}
	Dbg("line_limit=" + line_limit + "\n");
	sel_fields = parms.sel_fields;
	sort_keys = parms.sort_keys;
	sort_rev = parms.sort_rev;
	output_type = parms.output_type;
	output_dest = parms.output_dest;
	no_border = parms.no_border;
	search_parms = buildSearch(parms);
	search_result = findParms(search_parms);
	search_done = 1;
	showResults(search_result);
}

function
show_q1(q,n,op,v,conj) {
	document.write(mkSel("q",colnames,0,new Array(),0,q));
	document.write(mkSel("n",new Array("","not"),0,new Array(),n,null));
	document.write(mkSel("op",opnames,0,opcodes,0,op));
	document.write(mkText("v",v,20));
	document.write(mkSel("t",conjnames,0,conjcodes,0,conj));
	document.write("<br>");
}

function
redraw_select(qp) {
	var i, v;
	for (i = 0; (v = qp.values[i]) != null && v != ""; ++i) {
		show_q1(
			qp.queries[i],
			qp.nots[i],
			qp.ops[i],
			qp.values[i],
			qp.conjs[i]
		);
	}
}

function
showFields(qp) {
	var f, sel, v;
	var i = 0;
	if (qp != null && qp.sel_fields != null) {
		f = qp.sel_fields.concat();   // make a copy
		while (f.length > 0) {
			sel = new Array();
			sel.push(v = f.shift() - 0);
			while (f.length > 0) {
				// ick; special cases for 99 ... 98
				if (f[0] == 99) break;
				if (v > f[0] && (sel.length > 1 || v != 99))
					break;
				sel.push(v = f.shift() - 0);
			}
			document.write(mkMul("f",supcolnames,0,supcolnums,5,sel));
			++i;
		}
	}
	if (i < 1) document.write(mkMul("f",supcolnames,0,supcolnums,5,null));
	document.write(mkMul("f",supcolnames,0,supcolnums,5,null));
}

function
showSort(qp) {
	var f, sel, v;
	var i = 0;
	if (qp != null && qp.sort_keys != null) {
		f = qp.sort_keys.concat();   // make a copy
		while (f.length > 0) {
			sel = new Array();
			sel.push(v = f.shift() - 0);
			while (f.length > 0) {
				if (v > f[0])
					break;
				sel.push(v = f.shift() - 0);
			}
			document.write(mkMul("s",colnames,0,new Array(),5,sel));
			++i;
		}
	}
	if (i < 1) document.write(mkMul("s",colnames,0,new Array(),5,null));
	document.write(mkMul("s",colnames,0,new Array(),5,null));
}

document.writeln('<form name="find" method="GET" action="selana.html">');
if (more_query) {
	document.writeln('<hr>');
	oq = (qParms != null && qParms.line_limit != null);
	document.write("Show the first ");
	document.write(mkText("ls", oq?qParms.line_limit:50, 5));
	document.write(" results where:<br>");
	if (oq) {
		redraw_select(qParms);
	}
	else {
		show_q1(null,0,null,"",null);
		show_q1(null,0,null,"",null);
	}
	show_q1(null,0,null,"",null);
	show_q1(null,0,null,"",null);
	document.write(mkSel("q",colnames,0,new Array(),0));
	document.write(mkSel("n",new Array("","not"),0,new Array(),0));
	document.write(mkSel("op",opnames,0,opcodes,0));
	document.write(mkText("v","",20));
	document.write("<br><br>");

	document.write("For each record show:<br>");
	showFields(qParms);
	document.write("<br>(Choose zero or several from each list above)<br><br>");
	document.write("Sort in ");
	document.write(mkSel("sr",new Array("ascending","descending"),0,new Array(),0,oq?qArgs.sr:null));
	document.write("order by:<br>");
	showSort(qParms);
	document.write("<br>(Choose zero or several from each list above)<br><br>");
	document.write("Output format:");
	document.write(mkSel("ot",
			new Array("lotus","HTML Table","Brief HTML entries","Labeled HTML entries"),0,
			new Array("lotus","HTML","BRIEF","LABELED"),0,
			oq?qParms.output_type:null));
	document.write(mkSel("nb",
			new Array("border","no border"),0,
			new Array("0","1"),0,
			oq?qParms.no_border:null));
	document.write("<br>");
	document.write("Output Destination:");
	document.write(mkSel("od",new Array("text area","new page"),0,new Array("text","newpage"),0,oq?qParms.output_dest:null));
	document.writeln("<br>");
	document.write(mkSel("nq",new Array("Do","Do not"),0,new Array(),oq?qArgs.nq:0,0));
	document.writeln("&nbsp;display another query form<br>");
	
	document.writeln("<br>When ready, either of the following can be used to submit the query.<br>");
	document.writeln("<table border>");
	document.writeln("<tr><td><input type=\"button\" value=\"Quick Find\" onclick=\"dofind()\"></td><td>faster query (e.g. to text area which can be cut out), but results cannot be printed</td></tr>");
	document.writeln("<tr><td><input type=\"submit\"></td><td> slower, generates new page, can be printed, and can extend query form</td></tr>");
	document.writeln("</table>");
}
document.writeln('</form><br>');

// new form to prevent out_search being added to query URL

document.writeln('<form name="output">');
if (more_query || (qParms != null && qParms.output_dest == "text") ) {
	document.write("<br>The following is not for input; it is the optional output area.<br>");
	Dbg("output_dest=" + output_dest + "\n");
	Dbg("more_query=" + more_query + "\n");
	Dbg("\n");
	document.writeln("<textarea name=\"out_search\" cols=\"81\" rows=\"7\">");
	document.writeln("</textarea><br>");
	document.write("Results in the text area can easily be copied using cut-and-paste.<br><br>");
}
document.writeln('</form><br><hr>');

if (search_done != null && search_done > 0) {
	showResults(search_result);
}
if (qParms != null) {
	doquery(qParms);
}
else {
	Stat("Ready");
}
