use strict;
use warnings FATAL => 'all';
use Test::More tests => 15;
use URI::file;
use X11::GUITest qw(FindWindowLike GetWindowPos);

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');
ok($mech->can('get'));

$mech->x_resize_window(800, 600);

my ($win_id) = FindWindowLike('Mozilla::Mechanize');
my ($x, $y, $width, $height, $bor_w, $scr) = GetWindowPos($win_id);
is($width, 800);
is($height, 600);

my $url = URI::file->new_abs("t/html/load.html")->as_string;
ok($mech->get($url));
is($mech->title, 'Load Test');
like($mech->content, qr/Hello Load Test/);

is($mech->run_js('return document.title'), 'Load Test');
is($mech->run_js('return 2 + 3'), '5');

my $e = $mech->get_html_element_by_id('d');
ok($e);
is($e->GetClassName, 'hi');
is($mech->get_element_style($e, "color"), "rgb(0, 0, 0)");
is($mech->get_element_style_by_id("d", "background-color"), "transparent");

$mech->set_prompt_result("goo");
is($mech->run_js('return prompt("ggg");'), "goo");

