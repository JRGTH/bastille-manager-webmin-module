#!/usr/local/bin/perl
# fstab_create.cgi
# Manipulate jail fstab

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'create_errfstab'});

# Construct command and arguments.
if ($in{'mkdir'} == 1 ) {
	$mkdir = "yes";
} else {
	$mkdir = "";
	}
if ($in{'name'}) {
	$name = "$in{'name'}";
} else {
	$name = "";
	}
if ($in{'source'}) {
	$source = "$in{'source'}";
} else {
	$source = "";
	}
if ($in{'target'}) {
	$target = "$in{'target'}";
} else {
	$target = "";
	}
if ($in{'dirmod'} == 1 ) {
	$dirmod = "nullfs	ro	0	0";
} else {
	$dirmod = "nullfs	rw	0	0";
	}

$makedir = $mkdir;
$targetdir = "$config{'bastille_jailpath'}/$name/root/$in{'target'}";

if ($in{'source'} && $in{'target'}) {
	$cmdline = "\"$source	$target	$dirmod\"";
} else {
	$cmdline = "";
	}

$err = &jail_addfstab_cmd();
&error($err) if ($err);
&webmin_log("fstab");
&redirect("");
