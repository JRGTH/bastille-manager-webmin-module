#!/usr/local/bin/perl
# destroy.cgi
# Destroy bastille jail

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'delete_err'});
$err = &destroy_jail_cmd();
&error($err) if ($err);
&webmin_log("destroy");
&redirect("");
