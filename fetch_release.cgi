#!/usr/local/bin/perl
# fetch_release.cgi
# Download FreeBSD base release

require './bastille-manager-lib.pl';
&ReadParse();
&error_setup($text{'download_dlerr'});
$err = &download_release_cmd();
&error($err) if ($err);
&webmin_log("fetch_release");
&redirect("");
