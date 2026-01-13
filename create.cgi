#!/usr/local/bin/perl
# create.cgi
# Create standard bastille jail

require './bastille-manager-lib.pl';
&ReadParse();
&error_setup($text{'create_err'});

my $sys_release = &get_local_osrelease();

# Construct some command and arguments.
if ($in{'name'}) {
	$name = "$in{'name'}";
} else {
	$name = "";
}

if ($in{'ipx'}) {
	$ipx = "$in{'ipx'}";
} else {
	$ipx = "";
}

if ($in{'nic'}) {
	$netif = "$in{'nic'}";
} else {
	$netif = "";
}

if($in{'rel'}) {
	$rel = "$in{'rel'}";
} else {
	$rel = "";
}

if($in{'jail_type'} eq "DEFAULT" ) {
	$jail_type = "";
} else {
	$jail_type = $in{'jail_type'};
}

if($in{'vnet_type'} eq "DISABLED") {
	$vnet_type = "";
} else {
	$vnet_type = $in{'vnet_type'};
}

if ($vnet_type eq "Empty") {
	$cmdline = "$name";
} else {
	$cmdline = "$name $rel $ipx $netif";
	$nicset = "$nic";
}

$err = &jail_create_cmd();
&error($err) if ($err);
&webmin_log("create");
&redirect("");
