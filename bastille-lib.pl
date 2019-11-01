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
	$props_res="IPV4,NIC,PATH,ACTIVE,TMPL,CMD";
	}
else {
	$props_res="IPV4,NIC,PATH,ACTIVE,TMPL";
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

sub list_base_release
{
my @netmask = qw( 12.1-RELEASE 12.0-RELEASE 11.3-RELEASE 11.2-RELEASE );
return ( @netmask );
}

sub get_local_releases
{
# Use ls command, otherwise use bastille internal command to list all bases.
my $getreleases = "ls $config{'bastille_relpath'}";
my $releases = `$getreleases`;
}

# Set action buttons.
my $start_icon = "./images/start.png";
my $stop_icon = "./images/stop.png";
my $restart_icon = "./images/restart.png";

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

sub check_jail_status
{
$jail = $key;
$jailcheck = `jls | sed '1 d' | awk '{print \$3}' | grep -w '$jail'`;
if ($jailcheck) {
	# Enable stop and restart buttons and display check icon.
	$iconstat = "./images/check.png";
	#$showcmd = "<a href='stop.cgi?jails=$key'>Stop</a> | <a href='restart.cgi?jails=$key'>Restart</a>"
	$showcmd = "<a href='stop.cgi?jails=$key'><img src=$stop_icon></a> | <a href='restart.cgi?jails=$key'><img src=$restart_icon></a>"
	}
else {
	# Enable start and restart buttons and display stop icon.
	$iconstat = "./images/not.png";
	#$showcmd = "<a href='start.cgi?jails=$key'>Start</a> | <a href='restart.cgi?jails=$key'>Restart</a>";
	$showcmd = "<a href='start.cgi?jails=$key'><img src=$start_icon></a> | <a href='restart.cgi?jails=$key'><img src=$restart_icon></a>";
	}
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
print &ui_columns_start([ "JID", "NAME", @props ]);
foreach $key (sort(keys %jailr))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
	
	$jid = `/usr/sbin/jls | /usr/bin/grep $key | /usr/bin/awk '{print \$1}'`;
	$ipv4 = `/usr/bin/grep -w 'ip4.addr' $config{'bastille_jailpath'}/$key/jail.conf | /usr/bin/awk '{print \$3}' | /usr/bin/tr -d ';'`;
	$interface = `/usr/bin/grep -w 'interface' $config{'bastille_jailpath'}/$key/jail.conf | /usr/bin/awk '{print \$3}' | /usr/bin/tr -d ';'`;
	if (!$jid) {
		$jid = "-";
		}

		$custom_icon = "./images/$key\_icon.png";
		if (-e $custom_icon) {
			$template_icon = "./images/$key\_icon.png";
		} else {
			$template_icon = "./images/bsd_icon.png";
			}
	
	if ($config{'show_cmd'}) {
		&check_jail_status($key);
		print &ui_columns_row(["$jid", $key, "$ipv4", "$interface", "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
			"<img src=$iconstat>", "<img src=$template_icon>", "$showcmd"]);
	}
	else {
		&check_jail_status($key);
		print &ui_columns_row(["$jid", $key, "$ipv4", "$interface", "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
			"<img src=$iconstat>", "<img src=$template_icon>"]);
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
	print &ui_columns_row(["<a href='ui_jail_fstab.cgi?jailr=$key'>$key</a>",
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

push(@links2, "ui_release_fetch.cgi");
push(@titles2, $text{'download_icontext'});
push(@icons2, "images/download.gif");
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

sub download_release_cmd
{
if ($config{'show_advanced'}) {
	my $cmd = $in{'release'};
	local $out = `bastille bootstrap $cmd 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

sub delete_release_cmd
{
if ($config{'show_advanced'}) {
	my $cmd = $in{'release'};
	local $out = `bastille destroy $cmd 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

1;
