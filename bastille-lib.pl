#!/usr/local/bin/perl
# bastille-lib.pl

BEGIN { push(@INC, ".."); };
use WebminCore;
use File::Path qw/mkpath/;
&init_config();

# Default bastille jail list props.
# JID, IP Address, Hostname, Path
my $props_status="IP,HOSTNAME,PATH";

# Resource props.
if ($config{'show_cmd'}) {
	$props_res="PATH,CMD";
	}
else {
	$props_res="PATH";
}

# get_bastille_version()
sub get_bastille_version
{
my $getversion = 'bastille -v | perl -pe "s/\e\[[0-9;]*m//g"';
my $version = `$getversion`;
}

sub get_local_nics
{
my $getnics = 'ifconfig -l';
my $nics = `$getnics`;
}

sub get_local_releases
{
# Use ls command, otherwise use bastille internal command to list all bases.
my $getreleases = "ls $config{'bastille_relpath'}";
my $releases = `$getreleases`;
}

sub get_local_osrelease
{
my $getosrelease = "uname -r | sed 's/-p.*//'";
my $osrelaese = `$getosrelease`;
}

sub list_ipv4_netmask
{
my @netmask = qw( /24 /16 /8 );
return ( @netmask );
}

sub list_ipv6_netmask
{
my @netmask = qw( /64 /48 /32 );
return ( @netmask );
}

sub list_local_nics
{
my $localnics = get_local_nics();
my @nics = split(/\s+/, $localnics);
return ( @nics );
}

sub list_local_rels
{
my $localrels = get_local_releases();
if (!$localrels) {
	$localrels = get_local_osrelease();
	}
my @rels = split(/\s+/, $localrels);
return ( @rels );
}

sub list_jails
{
my %jails=();
my $list=`jls | sed "1 d"`;
open my $fh, "<", \$list;
while (my $line =<$fh>)
{
	chomp ($line);
	my @props = split(" ", $line);
		$ct = 1;
		foreach $prop (split(",", $props_status)) {
			$jails{$props[0]}{$prop} = $props[$ct];
			$ct++;
		}

}
return %jails;
}

# Jail summary list.
sub ui_jail_list
{
my %jails = list_jails($jails);
@props = split(/,/, $props_status);
# Check if commands enabled.
if ($config{'show_cmd'}) {
	print &ui_columns_start([ "JID", @props, "CMD" ]);
	}
else {
	print &ui_columns_start([ "JID", @props ]);
}
my $num = 0;
foreach $key (sort(keys %jails))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $jails{$key}{$prop}); }
	if ($config{'show_cmd'}) {
		# Enable start, stop and restart buttons.
		print &ui_columns_row([ "<a href='index.cgi?jails=$key'>$key</a>", @vals,
			"<a href='stop.cgi?jails=$jails{$key}{HOSTNAME}'>Stop</a> | <a href='restart.cgi?jails=$jails{$key}{HOSTNAME}'>Restart</a>"]);
		}
	else {
		# Disable start, stop and restart buttons.
		print &ui_columns_row([ "<a href='index.cgi?jails=$key'>$key</a>", @vals ]);
	}
	$num ++;
}
print &ui_columns_end();
}

sub list_res
{
my %jailr=();
my $list=`bastille list jail`;
open my $fh, "<", \$list;
while (my $line =<$fh>)
{
	chomp ($line);
	my @props = split(" ", $line);
		$ct = 1;
		foreach $prop (split(",", $props_res)) {
			$jailr{$props[0]}{$prop} = $props[$ct];
			$ct++;
		}

}
return %jailr;
}

# Jail resource list.
sub ui_jail_res
{
my %jailr = list_res($jailr);
@props = split(/,/, $props_res);
print &ui_columns_start([ "NAME", @props ]);
foreach $key (sort(keys %jailr))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
	if ($config{'show_cmd'}) {
		print &ui_columns_row([$key, "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
			"<a href='start.cgi?jails=$key'>Start</a> | <a href='stop.cgi?jails=$key'>Stop</a> | <a href='restart.cgi?jails=$key'>Restart</a>"]);
	}
	else {
		print &ui_columns_row([$key, "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>"]);
		#print &ui_columns_row(["$key"]);
	}
}
print &ui_columns_end();
}

sub ui_perjail_edit
{
my %jailr = list_res($jailr);
@props = split(/,/, $props_res);
print &ui_columns_start([ "NAME", "PATH" ]);
foreach $key (sort(keys %jailr))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
	print &ui_columns_row(["<a href='edit_perjail.cgi?jailr=$key'>$key</a>",
		"<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>" ]);
}
&unlink_record();
print &ui_columns_end();
}

sub ui_perjail_fstab
{
my %jailr = list_res($jailr);
@props = split(/,/, $props_res);
print &ui_columns_start([ "NAME", "PATH" ]);
foreach $key (sort(keys %jailr))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
	print &ui_columns_row(["<a href='ui_jail_addfstab.cgi?jailr=$key'>$key</a>",
		"<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>" ]);
}
&unlink_record();
print &ui_columns_end();
}

sub ui_perjail_destroy
{
my %jailr = list_res($jailr);
@props = split(/,/, $props_res);
print &ui_columns_start([ "NAME", "PATH" ]);
foreach $key (sort(keys %jailr))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
	print &ui_columns_row(["<a href='ui_jail_destroy.cgi?jailr=$key'>$key</a>",
		"<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>" ]);
}
&unlink_record();
print &ui_columns_end();
}

sub unlink_record
{
my $editfile = "$module_config_directory/last_edit";
if (-e $editfile ) {
	# Unlink previous record file.
	unlink "$module_config_directory/last_edit";
	}
}

sub ui_bastille_conf
{
# Display icons for options.
if ($config{'show_conf'}) {
	push(@links, "ui_perjail_edit.cgi");
	push(@titles, $text{'manual_jailedit'});
	push(@icons, "images/perjail.gif");

	push(@links, "edit_manual.cgi");
	push(@titles, $text{'manual_title'});
	push(@icons, "images/manual.gif");
	}
&icons_table(\@links, \@titles, \@icons, 4);
}

sub ui_bastille_advanced
{
# Display icons for options.
if ($config{'show_advanced'}) {
	push(@links2, "ui_jail_create.cgi");
	push(@titles2, $text{'manual_createjail'});
	push(@icons2, "images/create.gif");
	}

if ($config{'show_destroy'}) {
	push(@links2, "ui_perjail_destroy.cgi");
	push(@titles2, $text{'manual_deljail'});
	push(@icons2, "images/delete.gif");
	}

if ($config{'show_advanced'}) {
	push(@links2, "ui_perjail_fstab.cgi");
	push(@titles2, $text{'create_fstab'});
	push(@icons2, "images/dirtree.gif");
	}
&icons_table(\@links2, \@titles2, \@icons2, 4);
}

sub read_last_edit
{
my $editfile = "$module_config_directory/last_edit";
	if (open(my $fh, '<:encoding(UTF-8)', $editfile)) {
		while (my $row = <$fh>) {
		chomp $row;
		$item = "$row\n";
		$item =~ s/\s+//g;
		}
	}
}

# Start jail.
sub start_jail
{
my $jails = $in{'jails'};
if ($config{'show_cmd'}) {
	local $out = `$config{'start_cmd'} $jails 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

# Stop jail.
sub stop_jail
{
my $jails = $in{'jails'};
if ($config{'show_cmd'}) {
	local $out = `$config{'stop_cmd'} $jails 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

# Restart jail.
sub restart_jail
{
my $jails = $in{'jails'};
if ($config{'show_cmd'}) {
	local $out = `$config{'restart_cmd'} $jails 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

# Create jail.
sub jail_create_cmd
{
if ($config{'show_advanced'}) {
	my $cmd = $cmdline;
	local $out = `bastille create $cmd 2>&1 </dev/null`;

	if ($nicset) {
	`perl -p -i -e "s/interface = .*;/interface = $nicset;/g" $config{'bastille_jailpath'}/$name/jail.conf`;
	}

	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

# Destroy jail.
sub destroy_jail_cmd
{
if ($config{'show_destroy'}) {
	read_last_edit();
	if ($item ne $in{'name'}) {
		$item = "";
		}
		local $out = `bastille destroy $item 2>&1 </dev/null`;
		return "<pre>$out</pre>" if ($?);
		}
return undef;
}

# Add fstab.
sub jail_addfstab_cmd
{
if ($config{'show_advanced'}) {
	read_last_edit();
	if ($item ne $in{'name'}) {
		$item = "";
		}

	if ($makedir eq "yes") {
		unless(-e $targetdir or mkpath $targetdir) {
			`mkdir -p $targetdir`;
			}
		}

	my $cmd = $cmdline;
	if ($cmd) {
		local $out = `echo $cmd >> $config{'bastille_jailpath'}/$name/fstab 2>&1 </dev/null`;
		return "<pre>$out</pre>" if ($?);
		}
	}
return undef;
}

1;
