#!/usr/local/bin/perl
# export_jail.cgi
# Export FreeBSD jail

require './bastille-manager-lib.pl';
&ReadParse();
&error_setup($text{'export_err'});
$err = &export_jail_cmd();
&error($err) if ($err);
&webmin_log("export_jail");
&redirect("");
