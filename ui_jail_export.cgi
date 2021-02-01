#!/usr/local/bin/perl
# Show a page for manually download a FreeBSD base release

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

$txz_archive = "no";
$safe_zfsexp = "no";
my $iszfsmode = &get_zfs_mode();

print &ui_form_start("export_jail.cgi");
print &ui_table_start($text{'export_tittle'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'export_confirm'}, &ui_select("exp_jail", "$text{'export_combobox'}", [ &list_local_jails() ], 1, 0, 1));
	print &ui_table_row($text{'export_expath'}, &ui_textbox("exp_path", "", 30)." ". &file_chooser_button("path", 1));

	if ($iszfsmode =~ "YES") {
		print &ui_table_row($text{'export_txz'},
			&ui_yesno_radio("txz_archive", lc($txz_archive) eq 'no' ? 0 : lc($txz_archive) eq 'yes' ? 1 : 1));

		print &ui_table_row($text{'export_safebackup'},
			&ui_yesno_radio("safe_zfsexp", lc($safe_zfsexp) eq 'no' ? 0 : lc($safe_zfsexp) eq 'yes' ? 1 : 1));
	}
}

print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("export_jail.cgi", $text{'export_button'}, "<b>$text{'export_dlnote'}</b>");
print &ui_buttons_end();

&ui_print_footer("", $text{'index_return'});

