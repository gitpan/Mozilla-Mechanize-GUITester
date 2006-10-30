use strict;
use warnings FATAL => 'all';

use Test::More tests => 4;

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');

ok($mech->get('http://www.google.com'));
is($mech->status, 200);
