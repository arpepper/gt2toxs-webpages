// Copyright (c) 2001 Adrian Pepper, all rights reserved.
// Contact arpepper at math.uwaterloo.ca  for more information.

var more_query = 1;
var search_done;
var search_result;
var number_found;
var number_unique;
var search_parms = new Array();
var sort_keys = new Array();
var sort_rev = new Array();

var lines = new Array();
var linei = 0;
var field_select = "";
var sel_fields = new Array();
var prev_oline = "";
var line_count = 0;
var match_count = 0;
var line_limit = 65535;
var output_type = "lotus";
var no_border = false;
var output_dest = "text";

function
splitString(s) { // special to generate empty Array instead of 1st elt ""
	var a;
	if (s == null || s == "") {
		a = new Array();
		return a;
	}
	else {
		return s.split(",");
	}
}

function
parseParms(a) { // convert pre-parsed args, usu. from URL query to parms
	var p = new Object();
	var queries, nots, ops, values, conjs;
	var sel_fields, sort_keys, reverse;
	var line_limit, output_type, no_border, output_dest, more_query;
	var i;

Dbg("values: " + a.v + "\n");
	queries = (a.q == null) ? "" : a.q;  // query fields
	nots = (a.n == null) ? "" : a.n;
	ops = (a.op == null) ? "" : a.op;
	values = (a.v == null) ? "" : a.v;
	conjs = (a.t == null) ? "" : a.t;
	sel_fields = (a.f == null) ? "" : a.f;   // fields to print
	sort_keys = (a.s == null) ? "" : a.s;
	reverse = (a.sr == null) ? 0 : a.sr;
	line_limit = (a.ls == null) ? 50 : a.ls;
	output_type = (a.ot == null) ? "HTML" : a.ot;
	no_border = (a.nb == null) ? false : (a.nb > 0);
	output_dest = (a.od == null) ? "text" : a.od;
	more_query = (a.nq == null) ? true : (a.nq == 0);

	p.queries = splitString(queries); // query fields
	p.nots = splitString(nots);
	p.ops = splitString(ops);
	p.values = splitString(values);
	p.conjs = splitString(conjs);
	p.sel_fields = splitString(sel_fields);   // fields to print
	p.sort_keys = splitString(sort_keys);
	p.sort_rev = new Array();
	for (i=0; i < p.sort_keys.length; ++i) {
		p.sort_rev[i] = (reverse > 0);
	}
	p.line_limit = line_limit;
	p.output_type = output_type;
	p.no_border = no_border;
	p.output_dest = output_dest;
	p.more_query = more_query;

	return p;
}

function
getArgs(string) {  // pre-parse an argument string, usu. from URL query
	var args = new Object();
	var pairs = string.split("&");
	var i, pos, s, name, value;

	for (i = 0; (s = pairs[i]) != null; ++i) {
		Dbg( s + "==>");
		if ((pos = s.indexOf("=")) < 0) continue;
		name = s.substring(0,pos);
		value = s.substring(pos+1);
		if (args[name] != null) {
			// perhaps could convert to Array() right now
			// problem: some single-values also want to be Array()
			args[name] += "," + unescape(value);
		}
		else {
			args[name] = unescape(value);
		}
		Dbg( name + "," + value + "\n");
	}
	return args;
}

function Dummy_Object(v) {
	this.value = v;
}
function Dbg(s) {
	if (show_debug != 0) {
		document.debug.debug.value += s;
	}
}
function Stat(s) {
	if (more_query) {
		document.stat.stat.value = s;
	}
}

document.writeln('<form name="debug">');
var show_debug = 1;
show_debug = 0;
if (show_debug != 0) {
	document.write('<textarea name="debug" cols="81" rows="10"></textarea>');
	document.write('<br><textarea name="temp" cols="20" rows="1"></textarea>');
}

var query_string = location.search.substring(1);
var qArgs, qParms;
if (query_string != null && query_string != "") {
	qArgs = getArgs(query_string);
	qParms = parseParms(qArgs);
	more_query = qParms.more_query;
}
document.writeln('</form>');


//
document.writeln('<form name="stat">');
if (more_query) {
	document.write('<br><input type="text" name="stat" size="45" value="Loading Data"><br>');
}
document.writeln('</form>');
