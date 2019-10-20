#!/usr/local/bin/perl
# stop.cgi
# Stop bastille jail

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'stop_err'});
$err = &stop_jail();
&error($err) if ($err);
&webmin_log("stop");
&redirect("");
