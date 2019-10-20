#!/usr/local/bin/perl
# ui_jail_destroy.cgi
# Show a page for manually confirm for destroy an bastille jail

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

my $jail = $in{'jailr'};
#my $item = uc($jail);
my $item = $jail;

print &ui_form_start("destroy.cgi");
print &ui_table_start("$text{'perjail_destroytitle'} $item", "width=100%", 2);

# Record the last edited jail.
&write_file("$module_config_directory/last_edit", {""},$jail);

if ($config{'show_destroy'}) {
	print &ui_table_row($text{'delete_confirm'},
		&ui_opt_textbox("name", $jname, 30, $text{'create_default'}));

}

print &ui_table_end();

print &ui_buttons_start();
print &ui_buttons_row("destroy.cgi", $text{'delete_button'}, $text{'delete_delnote'});
print &ui_buttons_end();
print &ui_form_end();

&ui_print_footer("", $text{'index_return'});
