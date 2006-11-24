use strict;
use warnings FATAL => 'all';

use Test::More tests => 13;
use URI::file;

BEGIN { use_ok('Mozilla::Mechanize::GUITester'); }

my $mech = Mozilla::Mechanize::GUITester->new(quiet => 1, visible => 0);
isa_ok($mech, 'Mozilla::Mechanize::GUITester');

my $url = URI::file->new_abs("t/html/text.html")->as_string;
ok($mech->get($url));
is($mech->title, 'Text');

my $it = $mech->get_html_element_by_id("it");
my $input = $it->QueryInterface(Mozilla::DOM::HTMLInputElement->GetIID);
isnt($input, undef);
is($input->GetValue, 44);

$mech->x_change_text($it, "55");
is($input->GetValue, 55);
is($mech->last_alert, "changed with 55");

my $ta = $mech->get_html_element_by_id("ta");
isnt($ta, undef);

my $textarea = $ta->QueryInterface(Mozilla::DOM::HTMLTextAreaElement->GetIID);
isnt($textarea, undef);
is($textarea->GetValue, "Text Area\n");

$mech->x_change_text($ta, "New Area");
is($textarea->GetValue, "New Area");
is($mech->last_alert, "textarea changed with New Area");

