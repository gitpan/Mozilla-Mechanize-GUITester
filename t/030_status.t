use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');

ok($mech->get('http://search.cpan.org'));
is($mech->status, 200);
is_deeply($mech->console_messages, []);
$mech->close;
