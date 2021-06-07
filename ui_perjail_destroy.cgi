#!/usr/local/bin/perl
# ui_perjail_destroy.cgi
# Show a page for manually destroy an bastille jail

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

# Start jail destroy tab.
print &ui_table_start($text{'index_select'}, "width=100%", undef);
&ui_perjail_destroy();
print &ui_table_end();

print &ui_table_start($text{'index_selectr'}, "width=100%", undef);
&ui_release_destroy();
print &ui_table_end();

print "<br>$text{'index_deletejail'}";

&ui_print_footer("", $text{'index_return'});
