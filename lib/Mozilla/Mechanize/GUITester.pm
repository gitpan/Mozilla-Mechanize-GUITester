use strict;
use warnings FATAL => 'all';

package Mozilla::Mechanize::GUITester;
use base 'Mozilla::Mechanize';
use Mozilla::Mechanize::GUITester::Gesture;
use Mozilla::PromptService;
use Mozilla::ObserverService;
use X11::GUITest qw(ClickMouseButton :CONST
		PressMouseButton ReleaseMouseButton);
use File::Temp qw(tempdir);

our $VERSION = '0.01';

=head1 NAME

Mozilla::Mechanize::GUITester - enhances Mozilla::Mechanize with GUI testing.

=head1 SYNOPSIS

  use Mozilla::Mechanize::GUITester;

  # regular Mozilla::Mechanize initialization
  my $mech = Mozilla::Mechanize::GUITester->new(%mechanize_args);
  $mech->get_url($url);

  # convenience wrapper over GetElementById and QueryInterface
  my $elem = $mech->get_html_element_by_id("some_id");

  # click mouse at the element position + (1, 1)
  $mech->x_click($elem, 1, 1);

  # play with the mouse relative to the element position
  $mech->x_mouse_down($elem, 2, 2);
  $mech->x_mouse_move($elem, 4, 4);
  $mech->x_mouse_up($elem, 4, 4);

  # drag element to (2,3) relative to client window
  $mech->x_drag_and_drop($elem, 2, 3);

  # run some javascript code and print its result
  print $mech->run_js('return "js: " + 2');

  # find out HTTP response status (works only for HTTP protocol)
  print $mech->status;

=head1 DESCRIPTION

This module enhances Mozilla::Mechanize with convenience functions allowing
testing of DHTML/JavaScript rich pages.

It uses X11::GUITest to emulate mouse clicking, dragging and moving over
elements in DOM tree.

It also allows running of arbitrary javascript code in the page context and
getting back the results.

=head1 CONSTRUCTION

=head2 Mozilla::Mechanize::GUITester->new(%options);

This constructor delegates to Mozilla::Mechanize::new function. See
Mozilla::Mechanize manual for its description.

=cut
sub new {
	my $home = $ENV{HOME};
	my $td = tempdir("/tmp/mozilla_guitester_XXXXXX", CLEANUP => 1);
	$ENV{HOME} = $td;
	my $self = shift()->SUPER::new(@_);
	$ENV{HOME} = $home;
	$self->{_home} = $td;
	$self->{_popups} = {};
	Mozilla::PromptService::Register({ DEFAULT => sub {
		my $name = shift;
		$self->{_popups}->{$name} = [ @_ ];
	} });
	Mozilla::ObserverService::Register({
		'http-on-examine-response' => sub {
			my $channel = shift;
			$self->{_response_status} = $channel->responseStatus;
		},
	});
	return $self;
}

=head1 ACCESSORS

=head2 $mech->status

Returns last response status using Mozilla::ObserverService and
nsIHTTPChannel:responseStatus function.

Note that it works only for HTTP requests.

=cut
sub status { return shift()->{_response_status}; }

=head2 $mech->last_alert

Returns last alert contents intercepted through Mozilla::PromptService.

It is useful for communication from javascript.

=cut
sub last_alert { return shift()->{_popups}->{Alert}->[2]; }

=head1 METHODS

=head2 $mech->run_js($js_code)

Wraps $js_code with JavaScript function and invokes it. Its result is
returned as string and intercepted through C<alert()>.

See C<last_alert> accessor above.

=cut
sub run_js {
	my ($self, $js) = @_;
	my $code = <<ENDS;
function __guitester_run_js() {
	$js;
}
alert(__guitester_run_js());
ENDS
	$self->get("javascript:$code");
	return $self->last_alert;
}

sub gesture {
	my ($self, $e) = @_;
	return Mozilla::Mechanize::GUITester::Gesture->new({ element => $e });
}

=head2 $mech->get_html_element_by_id($html_id)

Uses GetElementById and QueryInterface to get Mozilla::DOM::HTMLElement.

See Mozilla::DOM documentation for more details.

=cut
sub get_html_element_by_id {
	my $e = shift()->get_document->GetElementById(shift()) or return;
	my $iid = Mozilla::DOM::HTMLElement->GetIID;
	return $e->QueryInterface($iid);
}

sub _with_gesture_do {
	my ($self, $elem, $func) = @_;
	my $g = $self->gesture($elem);
	$func->($g);
	my $run = 1;
	Glib::Timeout->add(100, sub { undef $run; });
	Gtk2->main_iteration while ($run || Gtk2->events_pending);
}

=head2 $mech->x_click($element, $x, $y)

Emulates mouse click at ($element.left + $x, $element.top + $y) coordinates.

=cut
sub x_click {
	my ($self, $entry, $by_left, $by_top) = @_;
	$self->_with_gesture_do($entry, sub {
		my $g = shift;
		$g->element_mouse_move($by_left, $by_top);
		ClickMouseButton(M_LEFT);
	});
}

=head2 $mech->x_drag_and_drop($element, $x, $y)

Drags and drops $element to ($x, $y) relative to window coordinates.

=cut
sub x_drag_and_drop {
	my ($self, $entry, $by_left, $by_top) = @_;
	$self->_with_gesture_do($entry, sub {
		my $g = shift;
		$g->element_mouse_move(0, 0);
		PressMouseButton(M_LEFT);
		$g->window_mouse_move($by_left, $by_top);
		ReleaseMouseButton(M_LEFT);
	});
}

=head2 $mech->x_mouse_down($element, $x, $y)

Presses left mouse button at ($element.left + $x, $element.top + $y).

=cut
sub x_mouse_down {
	my ($self, $entry, $by_left, $by_top) = @_;
	$self->_with_gesture_do($entry, sub {
		my $g = shift;
		$g->element_mouse_move($by_left, $by_top);
		PressMouseButton(M_LEFT);
	});
}

=head2 $mech->x_mouse_up($element, $x, $y)

Releases left mouse button at ($element.left + $x, $element.top + $y).

=cut
sub x_mouse_up {
	my ($self, $entry, $by_left, $by_top) = @_;
	$self->_with_gesture_do($entry, sub {
		my $g = shift;
		$g->element_mouse_move($by_left, $by_top);
		ReleaseMouseButton(M_LEFT);
	});
}

=head2 $mech->x_mouse_move($element, $x, $y)

Moves mouse to ($element.left + $x, $element.top + $y).

=cut
sub x_mouse_move {
	my ($self, $entry, $by_left, $by_top) = @_;
	$self->_with_gesture_do($entry, sub {
		my $g = shift;
		$g->element_mouse_move($by_left, $by_top);
	});
}

1;

=head1 AUTHOR

Boris Sukholitko <boriss@gmail.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

L<Mozilla::Mechanize|Mozilla::Mechanize>

=cut

