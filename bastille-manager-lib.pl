#!/usr/local/bin/perl
# bastille-manager-lib.pl

BEGIN { push(@INC, ".."); };
use WebminCore;
use File::Path qw/mkpath/;
&init_config();

# Latest bastille jail list props.
# JID  Name  Boot  Prio  State  Type  IP_Address  Published_Ports  Release  Tags
my $props_status="IP,HOSTNAME,PATH";

# Resource props.
if ($config{'show_cmd'}) {
	if ($config{'show_templates'}) {
		$props_res="Boot,Prio,State,Type,IP Address,Published Ports,Release,Tags,OS,CMD";
	}
else {
	$props_res="Boot,Prio,State,Type,IP Address,Published Ports,Release,Tags,CMD";
	}
}
else {
	if ($config{'show_templates'}) {
		$props_res="Boot,Prio,State,Type,IP Address,Published Ports,Release,Tags,OS";
	}
else {
	$props_res="Boot,Prio,State,Type,IP Address,Published Ports,Release,Tags";
	}
}

sub get_export_options
{
	my $def_export_opts = &backquote_command("/usr/bin/grep 'bastille_export_options=' $config{'bastille_confpath'} | cut -d '\"' -f2");
}

# get_bastille_version()
sub get_bastille_version
{
	my $version = &backquote_command("$config{'bastille_path'} -v | perl -pe 's/\e\[[][A-Za-z0-9];?[0-9]*m?//g'");
}

sub get_bastille_version_min
{
	my $version = &backquote_command("$config{'bastille_path'} -v | perl -pe 's/\e\[[][A-Za-z0-9];?[0-9]*m?//g;s/\.//g'");
}

sub get_local_nics
{
	my $nics = &backquote_command('ifconfig -l');
}

sub list_local_jails
{
	my $localjails = &backquote_command("$config{'bastille_path'} list jails");
	my @jails = split(/\s+/, $localjails);
	return ( @jails );
}

sub list_local_backups
{
	my $localbackups = &backquote_command("$config{'bastille_path'} list backups");
	my @backups = split(/\s+/, $localbackups);
	return ( @backups );
}

sub list_export_options
{
	my $iszfsmode = &get_zfs_mode();
	if ($iszfsmode =~ "YES") {
		$get_exp_opts = "--gz --xz --zst --raw --tgz --txz --tzst";
	} else {
		$get_exp_opts = "--tgz --txz --tzst";
	}
	my @exportopts = split(/\s+/, $get_exp_opts);
	return ( @exportopts );
}

sub list_jail_types
{
	if ($config{'show_linux'}) {
		$get_jail_type = "Thick Empty Linux";
	} else {
		$get_jail_type = "Thick Empty";
	}
	my @jailtype = split(/\s+/, $get_jail_type);
	return ( @jailtype );
}

sub list_vnet_types
{

	$get_vnet_type = "VNET BRIDGE";
	my @vnettype = split(/\s+/, $get_vnet_type);
	return ( @vnettype );
}

sub list_base_release
{
	my @baserels = split(' ', $config{'bastille_releases'});
	return ( @baserels );
}

sub get_local_releases
{
	# Use ls command, otherwise use bastille internal command to list all bases.
	my $releases = &backquote_command("echo \$(ls $config{'bastille_relpath'})");
}

sub get_installed_releases
{
	# Use ls command, otherwise use bastille internal command to list all bases.
	my $releases = &backquote_command("echo \$(ls $config{'bastille_relpath'}) | sed 's/\ /,\ /g'");
}

sub get_zfs_mode
{
	my $zfsmode = &backquote_command("/usr/bin/grep 'bastille_zfs_enable=' $config{'bastille_confpath'} | cut -d'\"' -f2");
}

# Set action buttons.
my $start_icon = "./images/start.png";
my $stop_icon = "./images/stop.png";
my $restart_icon = "./images/restart.png";

sub get_local_osrelease
{
	my $osrelaese = &backquote_command("freebsd-version | sed 's/\-[pP].*//'");
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
$jailcheck = &backquote_command("/usr/sbin/jls name | /usr/bin/awk '/^$jail\$/'");
if ($jailcheck) {
	# Enable stop and restart buttons and display check icon.
	$iconstat = "./images/check.png";
	$showcmd = "<a href='stop.cgi?jails=$key'><img src=$stop_icon></a> | <a href='restart.cgi?jails=$key'><img src=$restart_icon></a>"
	}
else {
	# Enable start and restart buttons and display stop icon.
	$iconstat = "./images/not.png";
	$showcmd = "<a href='start.cgi?jails=$key'><img src=$start_icon></a> | <a href='restart.cgi?jails=$key'><img src=$restart_icon></a>";
	}
}

sub list_jails
{
	my %jails=();
	my $list=&backquote_command("/usr/sbin/jls | sed '1d'");
	open my $fh, "<", \$list;
	while (my $line =<$fh>) {
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
	my $list=&backquote_command("$config{'bastille_path'} list jail");
	open my $fh, "<", \$list;
	while (my $line =<$fh>) {
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

sub list_release
{
	my %jailr=();
	my $list=&backquote_command("$config{'bastille_path'} list release");
	open my $fh, "<", \$list;
	while (my $line =<$fh>) {
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
	print &ui_columns_start([ "JID", "Name", @props ]);
	foreach $key (sort(keys %jailr)) {
		@vals = ();
		foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
		if ($key) {
			# Get some jail infos from 'bastille list' then dump data to temporary file.
			# JID  Name  Boot  Prio  State  Type  IP_Address  Published_Ports  Release  Tags
			&backquote_command("$config{'bastille_path'} list | grep -w $key | while read _jid _name _boot _prio _state _type _ip _ports _release _tag; do
				echo \$_jid \$_name \$_boot \$_prio \$_state \$_type \$_ip \$_ports \$_release \$_tag > /tmp/jail.$key.state; done");
			# Set some variables from the previous temporary file.
			$jid = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$1}'");
			$boot = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$3}'");
			$prio = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$4}'");
			$state = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$5}'");
			$type = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$6}'");
			$ipvx = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$7}'");
			$ports = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$8}'");
			$release = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$9}'");
			$tags = &backquote_command("cat /tmp/jail.$key.state | awk '{print \$10}'");

			# Cleanup temporary file.
			unlink "/tmp/jail.$key.state";
		}

		# Display custom template icons if available.
		$custom_icon = "./images/addons/$key\_icon.png";
		$plugin_icon = "$config{'bastille_jailpath'}/$key/plugin_icon.png";
		if ((-e $plugin_icon) && (!-e $custom_icon)) {
			&backquote_command("/bin/cp $plugin_icon $custom_icon");
		}
		if (-e $custom_icon) {
			$template_icon = "./images/addons/$key\_icon.png";
		} else {
			$is_linuxjail = &backquote_command("/usr/bin/grep linsysfs $config{'bastille_jailpath'}/$key/fstab");
			if ($is_linuxjail) {
				$template_icon = "./images/linux_icon.png";
			} else {
				$template_icon = "./images/bsd_icon.png";
				}
		}

		# Display jail state.
		if ($config{'show_cmd'}) {
			&check_jail_status($key);
			if ($config{'show_templates'}) {
				print &ui_columns_row(["$jid", $key, "$boot", "$prio", "$state", $type, $ipvx, $ports, $release, $tags, "<img src=$template_icon>", "$showcmd"]);
			}
			else {
				print &ui_columns_row(["$jid", $key, "$boot", "$prio", "$state", $type, $ipvx, $ports, $release, $tags, "$showcmd"]);
			}
		}
		else {
			&check_jail_status($key);
			if ($config{'show_templates'}) {
				print &ui_columns_row(["$jid", $key, "$boot", "$prio", "$state", $type, $ipvx, $ports, $release, $tags, "<img src=$template_icon>"]);
			}
			else {
				print &ui_columns_row(["$jid", $key, "$boot", "$prio", "$state", $type, $ipvx, $ports, $release, $tags]);
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
	foreach $key (sort(keys %jailr)) {
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
	foreach $key (sort(keys %jailr)) {
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
	foreach $key (sort(keys %jailr)) {
		@vals = ();
		foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
		print &ui_columns_row(["<a href='ui_jail_destroy.cgi?jailr=$key'>$key</a>",
			"<a href='../filemin/index.cgi?path=$config{'bastille_jailpath'}/$key'>$config{'bastille_jailpath'}/$key</a>" ]);
	}
	&unlink_record();
	print &ui_columns_end();
}

sub ui_release_destroy
{
	my %jailr = list_release($jailr);
	@props = split(/,/, $props_res);
	print &ui_columns_start([ "NAME", "PATH" ]);
	foreach $key (sort(keys %jailr)) {
		@vals = ();
		foreach $prop (@props) { push (@vals, $jailr{$key}{$prop}); }
		print &ui_columns_row(["<a href='ui_jail_destroy.cgi?jailr=$key'>$key</a>",
			"<a href='../filemin/index.cgi?path=$config{'bastille_relpath'}/$key'>$config{'bastille_jailpath'}/$key</a>" ]);
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
		local $out = &backquote_command("$config{'start_cmd'} $jails 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

# Stop jail.
sub stop_jail
{
	my $jails = $in{'jails'};
	if ($config{'show_cmd'}) {
		local $out = &backquote_command("$config{'stop_cmd'} $jails 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

# Restart jail.
sub restart_jail
{
	my $jails = $in{'jails'};
	if ($config{'show_cmd'}) {
		local $out = &backquote_command("$config{'restart_cmd'} $jails 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

# Create jail.
sub jail_create_cmd
{
	if ($config{'show_advanced'}) {

		# Set requested jail type option.
		if ($in{'jail_type'} eq "Thick") {
			$option = "-T";
		} elsif ($in{'jail_type'} eq "Empty") {
			$option = "-E";
		} elsif ($in{'jail_type'} eq "Linux") {
			$option = "-L";
		}

		# Set requested vnet type option.
		if ($in{'vnet_type'} eq "VNET") {
			$isvnet = "-V";
		} elsif ($in{'vnet_type'} eq "BRIDGE") {
			$isvnet = "-B";
		}

		if ($isvnet) {
			$option = "$option $isvnet";
		}

		my $cmd = "$cmdline";
		local $out = &backquote_command("$config{'bastille_path'} create $option $cmd 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

# Destroy jail.
sub destroy_jail_cmd
{
	if ($config{'show_destroy'}) {
		&read_last_edit();
		if ($item ne $in{'name'}) {
			$item = "";
			$opts = "";
		} else {
			# Confirmed to be destroyed.
			$opts = "--auto -y";
		}
		$template_icon = "./images/addons/$item\_icon.png";
		if (-e $template_icon) {
			$destroy_cmd = &backquote_command("$config{'bastille_path'} destroy $opts $item && /bin/rm $template_icon 2>&1 </dev/null");
		} else {
			$destroy_cmd = &backquote_command("$config{'bastille_path'} destroy $opts $item 2>&1 </dev/null");
		}
		local $out = $destroy_cmd;
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

# Add fstab.
sub jail_addfstab_cmd
{
	if ($config{'show_advanced'}) {
		&read_last_edit();
		if ($item ne $in{'name'}) {
			$item = "";
		}

		if ($makedir eq "yes") {
			unless(-e $targetdir or mkpath $targetdir) {
				&backquote_command("mkdir -p $targetdir");
			}
		}

		my $cmd = $cmdline;
		if ($cmd) {
			local $out = &backquote_command("echo $cmd >> $config{'bastille_jailpath'}/$name/fstab 2>&1 </dev/null");
			$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
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
		my $def_distfiles = &backquote_command("/usr/sbin/sysrc -f $config{'bastille_confpath'} -n bastille_bootstrap_archives");
		$opt_distfiles =~ s/\s+$//;
		$def_distfiles =~ s/\s+$//;

		if ($opt_distfiles) {
			# Override config distfiles list once.
			$set_distfiles = &backquote_command("/usr/sbin/sysrc -f $config{'bastille_confpath'} bastille_bootstrap_archives=\"base $opt_distfiles\"");
		}

		if ($selection eq "DAFAULT") {
			$sysrelease =~ s/\s+$//;
			$cmd = $sysrelease;
		} else {
			$cmd = $selection;
		}

		local $out = &backquote_command("/bin/echo 'Y' | $config{'bastille_path'} bootstrap $cmd 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);

		# Set back default distfiles.
		if ($set_distfiles) {
			&backquote_command("/usr/sbin/sysrc -f $config{'bastille_confpath'} bastille_bootstrap_archives=\"$def_distfiles\"");
		}
	}
	return undef;
}

sub export_jail_cmd
{
	if ($config{'show_advanced'}) {
		$export_opts="";
		$export_path="";
		$export_format="$in{'export_format'}";
		$export_defaults = &get_export_options();

		# Build the requested export options.
		if ($export_defaults =~ /^ *$/) {
			if ($in{'safe_zfsexp'} == 1) {
				$export_opts = "--auto $export_format";

			} elsif ($in{'hot_zfsexp'} == 1) {
				$export_opts = "--live $export_format";
			} else {
				$export_opts = "$export_format";
			}
		}

		# Set export path if defined.
		if ($in{'exp_path'}) {
			$export_path = $in{'exp_path'};
		}

		my $item = $in{'exp_jail'};
		local $out = &backquote_command("$config{'bastille_path'} export $export_opts $item $export_path 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

sub import_jail_cmd
{
	if ($config{'show_advanced'}) {
		$force_opt="";
		if ($in{'force_import'} == 1) {
			$force_opt = "-f";
		}
		my $item = $in{'imp_jail'};
		if ($in{'from_path'}) {
			$item = $in{'from_path'};
		}
		local $out = &backquote_command("$config{'bastille_path'} import $item $force_opt 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

sub delete_release_cmd
{
	if ($config{'show_advanced'}) {
		my $cmd = $in{'release'};
		local $out = &backquote_command("$config{'bastille_path'} destroy $cmd 2>&1 </dev/null");
		$out =~ s/\e\[[][A-Za-z0-9];?[0-9]*m?//g;
		return "<pre>$out</pre>" if ($?);
	}
	return undef;
}

1;
