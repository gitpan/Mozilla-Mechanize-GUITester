use strict;
use warnings FATAL => 'all';
use Test::More tests => 10;
use URI::file;

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');
ok($mech->can('get'));

my $url = URI::file->new_abs("t/html/load.html")->as_string;
ok($mech->get($url));
is($mech->title, 'Load Test');
like($mech->content, qr/Hello Load Test/);

is($mech->run_js('return document.title'), 'Load Test');
is($mech->run_js('return 2 + 3'), '5');

my $e = $mech->get_html_element_by_id('d');
ok($e);
is($e->GetClassName, 'hi');
