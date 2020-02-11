#!/usr/local/bin/perl
# import_jail.cgi
# Import FreeBSD jail

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'import_err'});
$err = &import_jail_cmd();
&error($err) if ($err);
&webmin_log("import_jail");
&redirect("");
