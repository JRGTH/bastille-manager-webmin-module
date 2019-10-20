#!/usr/local/bin/perl
# create.cgi
# Create standard bastille jail

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'create_err'});

# Construct command and arguments.
#if ($in{'boot'} == 1 ) {
#	$boot = "boot=on";
#} else {
#	$boot = "";
#	}
if ($in{'name'}) {
	$name = "$in{'name'}";
} else {
	$name = "";
	}
if ($in{'ip4'}) {
	$ip4 = "$in{'ip4'}";
} else {
	$ip4 = "";
	}
if ($in{'nic_def'} == 0) {
	$nic = "$in{'nic'}";
} else {
	$nic = "";
	}
if($in{'release_def'} == 0) {
	if($in{'rel'} eq "NONE") {
		$rel = "";
	} else {
		$rel = "$in{'rel'}";
		$rel =~ s/NONE//;
		}
} else {
	$rel = "";
	}

$cmdline = "$name $rel $ip4";
$nicset= "$nic";

$err = &jail_create_cmd();
&error($err) if ($err);
&webmin_log("create");
&redirect("");
