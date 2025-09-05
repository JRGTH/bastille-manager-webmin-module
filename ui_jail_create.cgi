#!/usr/local/bin/perl
# ui_jail_create.cgi
# Show a page for manually creating an bastille basic jail

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "", "intro");

# Start jail create.
my $nic_def = "default";
my $release_def = "default";
my $thick_jail = &options_support();
my $vnet_jail = &options_support();
my $bridge_vnet_jail = &options_support();
my $empty_jail = &options_support();
my $linux_jail = &options_support();

print &ui_form_start("create.cgi");
print &ui_table_start($text{'manual_createjail'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'create_fname'},
		&ui_textbox("name", $jname, 30, ));

	print &ui_table_row($text{'create_ipv4'},
		&ui_textbox("ip4", $jip4, 30, ));

	print &ui_table_row($text{'create_network'}, &ui_select("nic", uc($nic_def), [ &list_local_nics() ], 1, 0, 1));

	print &ui_table_row($text{'create_reltype'}, &ui_select("rel", uc($release_def), [ &list_local_rels() ], 1, 0, 1));

	if ($thick_jail) {
		$thick = "no";
		print &ui_table_row($text{'create_thickjail'},
			&ui_yesno_radio("thick", lc($thick) eq 'no' ? 0 : lc($thick) eq 'yes' ? 1 : 1));
	}

	if ($vnet_jail) {
		$vnet = "no";
		print &ui_table_row($text{'create_vnetjail'},
			&ui_yesno_radio("vnet", lc($vnet) eq 'no' ? 0 : lc($vnet) eq 'yes' ? 1 : 1));
	}

	if ($bridge_vnet_jail) {
		$bridge_vnet = "no";
		print &ui_table_row($text{'create_bridge_vnetjail'},
			&ui_yesno_radio("bridge_vnet", lc($bridge_vnet) eq 'no' ? 0 : lc($bridge_vnet) eq 'yes' ? 1 : 1));
	}

	if ($empty_jail) {
		$emptyjail = "no";
		print &ui_table_row($text{'create_emptyjail'},
			&ui_yesno_radio("emptyjail", lc($emptyjail) eq 'no' ? 0 : lc($emptyjail) eq 'yes' ? 1 : 1));
	}

	if ($config{'show_linux'}) {
		if ($linux_jail) {
			$linuxjail = "no";
			print &ui_table_row($text{'create_linuxjail'},
				&ui_yesno_radio("linuxjail", lc($linuxjail) eq 'no' ? 0 : lc($linuxjail) eq 'yes' ? 1 : 1));
		}
	}

}
print &ui_table_end();
print &ui_buttons_start();
print &ui_buttons_row("create.cgi", $text{'create_button'}, $text{'create_relnote'});
print &ui_buttons_end();
print &ui_form_end();

&ui_print_footer("", $text{'index_return'});
