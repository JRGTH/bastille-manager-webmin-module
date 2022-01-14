#!/usr/local/bin/perl
# ui_jail_fstab.cgi
# Show a page for manipulate jail fstab

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "", "intro");

my $jail = $in{'jailr'};
#my $item = uc($jail);
my $item = $jail;
my $mkdir = "no";
my $dirmod = "no";

# Record the last edited jail.
&write_file("$module_config_directory/last_edit", {""},$jail);

print &ui_form_start("fstab_create.cgi");
print &ui_table_start("$text{'create_fstabtitle'} $item", "width=100%", 2);

if ($config{'show_advanced'}) {
	print &ui_table_row($text{'create_mkdirs'},
		&ui_yesno_radio("mkdir", lc($mkdir) eq 'no' ? 0 : lc($mkdir) eq 'yes' ? 1 : 1));
	print &ui_table_row($text{'create_targetmode'},
		&ui_yesno_radio("dirmod", lc($dirmod) eq 'no' ? 0 : lc($dirmod) eq 'yes' ? 1 : 1));
	print &ui_hidden("name", $jail);

	print &ui_table_row($text{'create_sourcedir'},
	&ui_textbox("source", "", 30)." ".
	&file_chooser_button("path", 1));

	print &ui_table_row($text{'create_targetdir'},
	&ui_textbox("target", "$config{'bastille_jailpath'}/$jail/root/mnt/", 30)." ".
	&file_chooser_button("path", 1));
}
print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("fstab_create.cgi", $text{'create_button'}, $text{'create_newfstab'});
print &ui_buttons_end();
print &ui_form_end();

&ui_print_footer("", $text{'index_return'});
