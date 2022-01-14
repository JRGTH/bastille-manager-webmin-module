#!/usr/local/bin/perl
# Show a page for manually download a FreeBSD base release

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

$force_import = "no";

print &ui_form_start("import_jail.cgi");
print &ui_table_start($text{'import_tittle'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'import_confirm'}, &ui_select("imp_jail", "$text{'import_combobox'}", [ &list_local_backups() ], 1, 0, 1));
	print &ui_table_row($text{'import_path'}, &ui_textbox("from_path", "", 30)." ". &file_chooser_button("file", 2));
	print &ui_table_row($text{'import_force'},
		&ui_yesno_radio("force_import", lc($force_import) eq 'no' ? 0 : lc($force_import) eq 'yes' ? 1 : 1));
}

print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("import_jail.cgi", $text{'import_button'}, "<b>$text{'import_dlnote'}</b>");
print &ui_buttons_end();

&ui_print_footer("", $text{'index_return'});

