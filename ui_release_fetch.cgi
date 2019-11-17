#!/usr/local/bin/perl
# Show a page for manually download a FreeBSD base release

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

my $base_deflabel = $text{'index_defrelease'};
my $base_reldef = &get_local_osrelease();
my $sys_base_rel = `echo "$base_deflabel ($base_reldef)"`;

print &ui_form_start("fetch_release.cgi");
print &ui_table_start($text{'download_dl'}, "width=100%", 2);

my $release = get_local_osrelease();
my $rels = get_local_releases();
if ($rels) {
	$rellist = $rels;
} else {
	$rellist = "none";
}

if ($config{'show_advanced'}) {
	#print &ui_table_row($text{'download_confirm'},
	#	&ui_textbox("osrelease", $release, 30, ));

		print &ui_table_row($text{'download_confirm'}, &ui_select("release", $sys_base_rel, [ &list_base_release() ], 1, 0, 1));

}

print &ui_table_row($text{'create_relavail'}, $rellist);
print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("fetch_release.cgi", $text{'download_button'}, "<b>$text{'download_dlnote'}</b>");
print &ui_buttons_end();

&ui_print_footer("", $text{'index_return'});

