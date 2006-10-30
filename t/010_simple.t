use strict;
use warnings FATAL => 'all';
use Test::More tests => 8;
use URI::file;

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');

my $url = URI::file->new_abs("t/html/simple_gui.html")->as_string;
ok($mech->get($url));
is($mech->title, 'Simple GUI');

my $e = $mech->get_document->GetElementById("but");
my $g = $mech->gesture($e);
ok($g);
is($g->element_x, $g->window_x + 8);
is($g->element_y, $g->window_y + 8);

$mech->x_click($e, 0, 0);
is($mech->last_alert, "clicked");
