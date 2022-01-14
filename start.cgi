#!/usr/local/bin/perl
# start.cgi
# Start bastille jail

require './bastille-manager-lib.pl';
&ReadParse();
&error_setup($text{'start_err'});
$err = &start_jail();
&error($err) if ($err);
&webmin_log("start");
&redirect("");
