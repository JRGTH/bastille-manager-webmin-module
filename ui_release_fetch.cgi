#!/usr/local/bin/perl
# Show a page for manually download a FreeBSD base release

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

my $sys_base_rel = "DAFAULT";

print &ui_form_start("fetch_release.cgi");
print &ui_table_start($text{'download_dl'}, "width=100%", 2);

my $rels = &get_local_releases();
if ($rels) {
	$rellist = $rels;
} else {
	$rellist = "none";
}

print &ui_table_row($text{'create_relavail'}, $rellist);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'download_confirm'}, &ui_select("release", $sys_base_rel, [ &list_base_release() ], 1, 0, 1));
	print &ui_table_row($text{'download_optdistfiles'});
	print &ui_table_row($text{'download_lib32'}, &ui_checkbox("opt_lib32", "lib32", "lib32.txz", &indexof("lib32.txz", "lib32.txz") >= 1)." ");
	print &ui_table_row($text{'download_ports'}, &ui_checkbox("opt_ports", "ports", "ports.txz", &indexof("ports.txz", "ports.txz") >= 1)." ");
	print &ui_table_row($text{'download_src'}, &ui_checkbox("opt_src", "src", "src.txz", &indexof("src.txz", "src.txz") >= 1)." ");
}

print &ui_table_end();
print &ui_buttons_start();
print &ui_buttons_row("fetch_release.cgi", $text{'download_button'}, "<b>$text{'download_dlnote'}</b>");
print &ui_buttons_end();

&ui_print_footer("", $text{'index_return'});

