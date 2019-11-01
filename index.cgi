#!/usr/local/bin/perl
# index.cgi

require './bastille-lib.pl';

# Check if bastille exists.
if (!&has_command($config{'bastille_path'})) {
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1);
	print &text('index_errbastille', "<tt>$config{'bastille_path'}</tt>",
		"$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	&ui_print_footer("/", $text{"index"});
	exit;
	}

# Get bastille version.
my $version = &get_bastille_version();
if (!$version == "blank") {
	# Display version.
	&write_file("$module_config_directory/version", {""},$version);
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1, 0,
		&help_search_link("BastilleBSD", "man", "doc", "google"), undef, undef,
		&text('index_version', "$text{'index_modver'} $version"));
	}
else {
	# Don't display version.
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1, 0,
		&help_search_link("BastilleBSD", "man", "doc", "google"), undef, undef,
		&text('index_version', ""));
}

# Start tabs.
@tabs = ();
push(@tabs, [ "res", $text{'index_jailres'}, "index.cgi?mode=res" ]);
if ($config{'show_conf'}) {
	push(@tabs, [ "conf", $text{'index_edit'}, "index.cgi?mode=conf" ]);
	}
if ($config{'show_advanced'}) {
	push(@tabs, [ "advanced", $text{'index_advanced'}, "index.cgi?mode=advanced" ]);
	}
print &ui_tabs_start(\@tabs, "mode", $in{'mode'} || $tabs[0]->[0], 1);

# Start jail resource tab.
print &ui_tabs_start_tab("mode", "res");
&ui_jail_res();
print &ui_tabs_end_tab("mode", "res");

# Start bastille config tab.
if ($config{'show_conf'}) {
	print &ui_tabs_start_tab("mode", "conf");
	&ui_bastille_conf();
	print &ui_tabs_end_tab("mode", "conf");
	}

# Start bastille advanced tab.
if ($config{'show_advanced'}) {
	print &ui_tabs_start_tab("mode", "advanced");
	&ui_bastille_advanced();
	print &ui_tabs_end_tab("mode", "advanced");
	}

# End tabs.
print &ui_tabs_end(1);

&ui_print_footer("/", $text{'index'});
