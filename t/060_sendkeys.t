use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;
use URI::file;

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');

my $url = URI::file->new_abs("t/html/keys.html")->as_string;
ok($mech->get($url));
is($mech->title, 'Keys');

is($mech->get_element_style_by_id("td", "width"), '30px');

$mech->x_send_keys('{DEL}');
is($mech->last_alert, 46);
