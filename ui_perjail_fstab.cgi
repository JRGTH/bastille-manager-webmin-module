#!/usr/local/bin/perl
# ui_perjail_fstab.cgi
# Show a page for manipulate jail fstab

require './bastille-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

# Start manipulate fstab.
print &ui_table_start($text{'index_select'}, "width=100%", undef);
&ui_perjail_fstab();
print &ui_table_end();

&ui_print_footer("", $text{'index_return'});
