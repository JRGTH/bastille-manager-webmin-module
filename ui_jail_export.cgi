#!/usr/local/bin/perl
# Show a page for manually download a FreeBSD base release

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

print &ui_form_start("export_jail.cgi");
print &ui_table_start($text{'export_tittle'}, "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'export_confirm'}, &ui_select("exp_jail", "$text{'export_combobox'}", [ &list_local_jails() ], 1, 0, 1));
}

print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("export_jail.cgi", $text{'export_button'}, "<b>$text{'export_dlnote'}</b>");
print &ui_buttons_end();

&ui_print_footer("", $text{'index_return'});

