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
	if ($config{'show_templates'}) {
		$props_res="IP,RELEASE,NIC,PATH,ACTIVE,TEMPLATE,CMD";
		}
	else {
		$props_res="IP,RELEASE,NIC,PATH,ACTIVE,CMD";
		}
	}
else {
	if ($config{'show_templates'}) {
		$props_res="IP,RELEASE,NIC,PATH,ACTIVE,TEMPLATE";
		}
	else {
		$props_res="IP,RELEASE,NIC,PATH,ACTIVE";
		}
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

sub list_local_jails
{
my $localjails = `$config{'bastille_path'} list jails`;
my @jails = split(/\s+/, $localjails);
return ( @jails );
}

sub list_local_backups
{
my $localbackups = `$config{'bastille_path'} list backups`;
my @backups = split(/\s+/, $localbackups);
return ( @backups );
}

sub list_base_release
{
my @baserels = qw( 12.1-RELEASE 12.0-RELEASE 11.3-RELEASE 11.2-RELEASE );
return ( @baserels );
}

sub get_local_releases
{
# Use ls command, otherwise use bastille internal command to list all bases.
my $getreleases = "echo \$(ls $config{'bastille_relpath'}) | sed 's/\ /,\ /g'";
my $releases = `$getreleases`;
}

# Set action buttons.
my $start_icon = "./images/start.png";
my $stop_icon = "./images/stop.png";
my $restart_icon = "./images/restart.png";

# Check if bastille support for options
sub options_support
{
my $options_support = `$config{'bastille_path'} create | /usr/bin/grep -wo "option"`;
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

sub check_jail_status
{
$jail = $key;
$jailcheck = `/usr/sbin/jls name | /usr/bin/awk '/^$jail\$/'`;
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
my $list=`/usr/sbin/jls | sed "1 d"`;
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
my $list=`$config{'bastille_path'} list jail`;
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

	# Get some jail info from either jls or config.
	$jid = `/usr/sbin/jls -j $key | /usr/bin/awk '/$key/ {print \$1}'`;
	$ipvx = `/usr/bin/grep -w 'ip4.addr' $config{'bastille_jailpath'}/$key/jail.conf | /usr/bin/awk '{print \$3}' | /usr/bin/tr -d ';'`;
	$interface = `/usr/bin/grep -w 'interface' $config{'bastille_jailpath'}/$key/jail.conf | /usr/bin/awk '{print \$3}' | /usr/bin/tr -d ';'`;
	$osrel = `/usr/sbin/jexec $key freebsd-version 2>/dev/null`;

	if (!$jid) {
		$jid = "-";
		}

	if (!$ipvx) {
		$ipvx = `/usr/bin/grep -w 'ip6.addr' $config{'bastille_jailpath'}/$key/jail.conf | /usr/bin/awk '{print \$3}' | /usr/bin/tr -d ';'`;
		}
	if (!$ipvx) {
		$ipvx = "-";
		}

	if (!$interface) {
		$interface = "-";
		}

	if (!$osrel) {
		$osrel = "-";
		}

	$custom_icon = "./images/$key\_icon.png";
	if (-e $custom_icon) {
		$template_icon = "./images/$key\_icon.png";
	} else {
		$template_icon = "./images/bsd_icon.png";
		}

	if ($config{'show_cmd'}) {
		&check_jail_status($key);
		if ($config{'show_templates'}) {
			print &ui_columns_row(["$jid", $key, "$ipvx", "$osrel", "$interface", "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
				"<img src=$iconstat>", "<img src=$template_icon>", "$showcmd"]);
			}
		else {
			print &ui_columns_row(["$jid", $key, "$ipvx", "$osrel", "$interface", "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
				"<img src=$iconstat>", "$showcmd"]);
			}	
	}
	else {
		&check_jail_status($key);
		if ($config{'show_templates'}) {
			print &ui_columns_row(["$jid", $key, "$ipvx", "$osrel", "$interface", "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
				"<img src=$iconstat>", "<img src=$template_icon>"]);
			}
		else {
			print &ui_columns_row(["$jid", $key, "$ipvx", "$osrel", "$interface", "<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>",
				"<img src=$iconstat>"]);
			}
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

if ($config{'show_advanced'}) {
	push(@links2, "ui_release_fetch.cgi");
	push(@titles2, $text{'download_icontext'});
	push(@icons2, "images/download.gif");
	}

if ($config{'show_advanced'}) {
	push(@links2, "ui_jail_export.cgi");
	push(@titles2, $text{'export_icontext'});
	push(@icons2, "images/backup.gif");
	}

if ($config{'show_advanced'}) {
	push(@links2, "ui_jail_import.cgi");
	push(@titles2, $text{'import_icontext'});
	push(@icons2, "images/import.gif");
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

	if ($in{'thick'} == 1 ) {
		$option = "-T";
		}
	else {
		$option = "";
	}

	if ($in{'vnet'} == 1 ) {
		$option2 = "-V";
		}
	else {
		$option2 = "";
	}

	if ($nicset) {
		if ($nicset eq "NONE") {
			$opt = "";
			}
		else {
			$opt = $nicset;
			}
		}
	else {
		$opt = "";
	}

	my $cmd = "$cmdline $opt";
	local $out = `$config{'bastille_path'} create $option $option2 $cmd 2>&1 </dev/null`;

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
		local $out = `$config{'bastille_path'} destroy $item 2>&1 </dev/null`;
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
	my $selection = $in{'release'};
	my $sysrelease = &get_local_osrelease();
	my $opt_distfiles = "$in{'opt_lib32'} $in{'opt_ports'} $in{'opt_src'}";
	my $def_distfiles = `/bin/cat $config{'bastille_confpath'} | /usr/bin/grep 'bastille_bootstrap_archives=' | /usr/bin/cut -d'"' -f2`;
	$opt_distfiles =~ s/\s+$//;
	$def_distfiles =~ s/\s+$//;

	if ($opt_distfiles) {
		# Override config distfiles list once.
		$set_distfiles = `/usr/sbin/sysrc -f $config{'bastille_confpath'} bastille_bootstrap_archives=\"base $opt_distfiles\"`;
		}

	if ($selection eq "DAFAULT") {
		$sysrelease =~ s/\s+$//;
		$cmd = $sysrelease;
	} else {
		$cmd = $selection;
		}

	local $out = `$config{'bastille_path'} bootstrap $cmd 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);

	# Set back default distfiles.
	`/usr/sbin/sysrc -f $config{'bastille_confpath'} bastille_bootstrap_archives=\"$def_distfiles\"`;
	}
return undef;
}

sub export_jail_cmd
{
if ($config{'show_advanced'}) {
	my $item = $in{'exp_jail'};
	local $out = `$config{'bastille_path'} export $item 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

sub import_jail_cmd
{
if ($config{'show_advanced'}) {
	my $item = $in{'imp_jail'};
	local $out = `$config{'bastille_path'} import $item 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

sub delete_release_cmd
{
if ($config{'show_advanced'}) {
	my $cmd = $in{'release'};
	local $out = `$config{'bastille_path'} destroy $cmd 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
return undef;
}

1;
