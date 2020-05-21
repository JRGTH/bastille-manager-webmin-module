#!/usr/local/bin/perl
# create.cgi
# Create standard bastille jail

require './bastille-lib.pl';
&ReadParse();
&error_setup($text{'create_err'});

my $sys_release = &get_local_osrelease();

# Construct command and arguments.
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

#if ($in{'nic_def'} == 0) {
#	$nic = "$in{'nic'}";
#} else {
#	$nic = "";
#}

if ($in{'nic'} eq "DEFAULT") {
	$netif = "";
} else {
	$netif = "$in{'nic'}";
}

#if($in{'release_def'} == 0) {
#	if($in{'rel'} eq "DEFAULT") {
#		$rel = "";
#	} else {
#		$rel = "$in{'rel'}";
#		$rel =~ s/DEFAULT//;
#	}
#} else {
#	$rel = "";
#}

if($in{'rel'} eq "DEFAULT") {
	$rel = $sys_release;
	$rel =~ s/\s+//g;
} else {
	$rel = "$in{'rel'}";
	#$rel =~ s/DEFAULT//;
}

if ($in{'emptyjail'} == 1) {
	$cmdline = "$name";
} else {
	$cmdline = "$name $rel $ip4 $netif";
	$nicset = "$nic";
}

$err = &jail_create_cmd();
&error($err) if ($err);
&webmin_log("create");
&redirect("");
