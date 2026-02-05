#!/usr/local/bin/perl
# save_perjail.cgi
# Update a manually edited config file

require './bastille-manager-lib.pl';
&error_setup($text{'manual_err'});
&ReadParseMime();

# Work out the file
my $editfile = "$module_config_directory/last_edit";
if (open(my $fh, '<:encoding(UTF-8)', $editfile)) {
	while (my $row = <$fh>) {
		chomp $row;
		$line = "$row\n";
		$line =~ s/\s+//g;
	}
}
my $jail = $line;

@files = ( "$config{'bastille_jailpath'}/$jail/fstab", "$config{'bastille_jailpath'}/$jail/jail.conf", "$config{'bastille_jailpath'}/$jail/settings.conf" );
&indexof($in{'file'}, @files) >= 0 || &error($text{'manual_efile'});
$in{'data'} =~ s/\r//g;
$in{'data'} =~ /\S/ || &error($text{'manual_edata'});

# Write to it
&open_lock_tempfile(DATA, ">$in{'file'}");
&print_tempfile(DATA, $in{'data'});
&close_tempfile(DATA);

&webmin_log("manual", undef, $in{'file'});
&redirect("");
