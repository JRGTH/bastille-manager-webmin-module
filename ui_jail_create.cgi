#!/usr/local/bin/perl
# ui_jail_create.cgi
# Show a page for manually creating an bastille basic jail

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "", "intro");

# Start jail create.
my $nic_def = "none";
#my $netmask_def = "none";
#my $netmaskv6_def = "none";
my $release_def = "none";
my $thick_jail = &options_support();
my $vnet_jail = &options_support();

print &ui_form_start("create.cgi");
print &ui_table_start($text{'manual_createjail'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	#$boot = "no";
	#print &ui_table_row($text{'create_autoboot'},
	#	&ui_yesno_radio("boot", lc($boot) eq 'no' ? 0 : lc($boot) eq 'yes' ? 1 : 1));

	print &ui_table_row($text{'create_fname'},
		&ui_textbox("name", $jname, 30, ));

	print &ui_table_row($text{'create_ipv4'},
		&ui_textbox("ip4", $jip4, 30, ));

	#print &ui_table_row($text{'create_ipv6'},
	#	&ui_opt_textbox("ip6", $jip6, 30, $text{'create_default'}));

	print &ui_table_row($text{'create_network'},
		&ui_radio("nic_def", $nic ? 0 : 1,
			[ [ 1, $text{'create_preset'} ],
			  [ 0, &ui_select("nic", uc($nic_def),
				[ &list_local_nics() ], 1, 0,
				"nic_def" ? 1 : 0) ] ]));

	#print &ui_table_row($text{'create_ipv4mask'},
	#	&ui_radio("netmask_def", $mask ? 0 : 1,
	#		[ [ 1, $text{'create_preset'} ],
	#		  [ 0, &ui_select("mask", uc($netmask_def),
	#			[ &list_ipv4_netmask() ], 1, 0,
	#			"netmask_def" ? 1 : 0) ] ]));
				#&ui_select("mask", uc($netmask_def), [ &list_ipv4_netmask() ], 1, 0, $netmask_def ));

	#print &ui_table_row($text{'create_ipv6mask'},
	#	&ui_radio("netmaskv6_def", $maskv6 ? 0 : 1,
	#		[ [ 1, $text{'create_preset'} ],
	#		  [ 0, &ui_select("maskv6", uc($netmaskv6_def),
	#			[ &list_ipv6_netmask() ], 1, 0,
	#			"netmaskv6_def" ? 1 : 0) ] ]));
	#			#&ui_select("maskv6", uc($netmaskv6_def), [ &list_ipv6_netmask() ], 1, 0, $netmaskv6_def ));

	print &ui_table_row($text{'create_reltype'},
		&ui_radio("release_def", $rel ? 0 : 1,
			[ [ 1, $text{'create_preset'} ],
			  [ 0, &ui_select("rel", uc($release_def),
				[ &list_local_rels() ], 1, 0,
				"release_def" ? 1 : 0) ] ]));
				#&ui_select("rel", uc($release_def), [ &list_local_rels() ], 1, 0, $release_def ));

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
}
print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("create.cgi", $text{'create_button'}, $text{'create_relnote'});
print &ui_buttons_end();
print &ui_form_end();

&ui_print_footer("", $text{'index_return'});
