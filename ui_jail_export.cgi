#!/usr/local/bin/perl
# Show a page for manually download a FreeBSD base release

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

my $safe_zfsexp = "no";
my $hot_zfsexp = "no";
my $export_item = "$text{'export_combobox'}";
my $export_def = "$text{'export_combobox'}";
my $iszfsmode = &get_zfs_mode();
my $export_defaults = &get_export_options();

print &ui_form_start("export_jail.cgi");
print &ui_table_start($text{'export_tittle'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'export_confirm'}, &ui_select("exp_jail", lc($export_item), [ &list_local_jails() ], 1, 0, 1));
	if ($export_defaults =~ /^ *$/) {
		print &ui_table_row($text{'export_options'}, &ui_select("export_format", lc($export_def), [ &list_export_options() ], 1, 0, 1));
		if ($iszfsmode =~ "YES") {
			print &ui_table_row($text{'export_safebackup'},
				&ui_yesno_radio("safe_zfsexp", lc($safe_zfsexp) eq 'no' ? 0 : lc($safe_zfsexp) eq 'yes' ? 1 : 1));
			print &ui_table_row($text{'export_hotbackup'},
				&ui_yesno_radio("hot_zfsexp", lc($hot_zfsexp) eq 'no' ? 0 : lc($hot_zfsexp) eq 'yes' ? 1 : 1));
		} else {
			print &ui_table_row($text{'export_safebackup'},
				&ui_yesno_radio("safe_zfsexp", lc($safe_zfsexp) eq 'no' ? 0 : lc($safe_zfsexp) eq 'yes' ? 1 : 1));
		}
	} else {
		 print &ui_table_row("$text{'export_defoptions'}: ($export_defaults)");
	}
	print &ui_table_row($text{'export_expath'}, &ui_textbox("exp_path", "", 30)." ". &file_chooser_button("path", 1));
}

print &ui_table_end();
print &ui_buttons_start();
print &ui_buttons_row("export_jail.cgi", $text{'export_button'}, "<b>$text{'export_dlnote'}</b>");
print &ui_buttons_end();

&ui_print_footer("", $text{'index_return'});
