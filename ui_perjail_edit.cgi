#!/usr/local/bin/perl
# ui_perjail_edit.cgi
# Show a page for manually editing an bastille config file

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

# Start jail edit tab.
print &ui_table_start($text{'index_select'}, "width=100%", undef);
&ui_perjail_edit();
print &ui_table_end();

print "<br>$text{'index_configselect'}";

&ui_print_footer("", $text{'index_return'});
