#!/usr/local/bin/perl
# restart.cgi
# Restart bastille jail

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'restart_err'});
$err = &restart_jail();
&error($err) if ($err);
&webmin_log("restart");
&redirect("");
