#!/usr/local/bin/perl
# edit_perjail.cgi
# Show a page for manually editing an bastille config file

require './bastille-manager-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

# Work out and show the files
my $editfile = "$module_config_directory/last_edit";
if (!-e $editfile ) {
	my $jail = $in{'jailr'};
	# Record the last edited jail.
	&write_file("$module_config_directory/last_edit", {""},$jail);
}

if (open(my $fh, '<:encoding(UTF-8)', $editfile)) {
	while (my $row = <$fh>) {
		chomp $row;
		$line = "$row\n";
		$line =~ s/\s+//g;
	}
}
my $jail = $line;

@files = ( "$config{'bastille_jailpath'}/$jail/fstab", "$config{'bastille_jailpath'}/$jail/jail.conf" );
$in{'file'} ||= $files[0];
&indexof($in{'file'}, @files) >= 0 || &error($text{'manual_efile'});
print &ui_form_start("edit_perjail.cgi");
print "<b>$text{'manual_file'}</b>\n";
print &ui_select("file", $in{'file'},
		 [ map { [ $_ ] } @files ]),"\n";
print &ui_submit($text{'manual_ok'});
print &ui_form_end();

# Show the file contents
print &ui_form_start("save_perjail.cgi", "form-data");
print &ui_hidden("file", $in{'file'}),"\n";
$data = &read_file_contents($in{'file'});
print &ui_textarea("data", $data, 20, 80),"\n";
print "<b>$text{'manual_editnote'}<b>";
print &ui_form_end([ [ "save", $text{'save'} ] ]);

&ui_print_footer("", $text{'index_return'});
