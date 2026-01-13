#!/usr/local/bin/perl
# ui_jail_create.cgi
# Show a page for manually creating an bastille basic jail

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "", "intro");

# Start jail create.
my $nic_def = "";
my $release_def = "";
my $jailtype_def = "dafault";
my $vnettype_def = "";
my $vnetmode_def = "disabled";

print &ui_form_start("create.cgi");
print &ui_table_start($text{'manual_createjail'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'create_fname'},
		&ui_textbox("name", $jname, 30, ));

	print &ui_table_row($text{'create_ipvx'},
		&ui_textbox("ipx", $jipx, 30, ));

	print &ui_table_row($text{'create_network'}, &ui_select("nic", lc($nic_def), [ &list_local_nics() ], 1, 0, 1));

	print &ui_table_row($text{'create_reltype'}, &ui_select("rel", lc($release_def), [ &list_local_rels() ], 1, 0, 1));

	print &ui_table_row($text{'create_jailtype'}, &ui_select("jail_type", uc($jailtype_def), [ &list_jail_types() ], 1, 0, 1));

	print &ui_table_row($text{'create_vnettype'}, &ui_select("vnet_type", uc($vnetmode_def), [ &list_vnet_types() ], 1, 0, 1));
}

print &ui_table_end();
print &ui_buttons_start();
print &ui_buttons_row("create.cgi", $text{'create_button'}, $text{'create_relnote'});
print &ui_buttons_end();
print &ui_form_end();

&ui_print_footer("", $text{'index_return'});
