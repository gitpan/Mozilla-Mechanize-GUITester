use strict;
use warnings FATAL => 'all';

package Mozilla::Mechanize::GUITester::Gesture;
use base 'Class::Accessor';
use Mozilla::DOM;
use X11::GUITest qw(FindWindowLike GetWindowPos MoveMouseAbs);

__PACKAGE__->mk_accessors(qw(element element_top element_left window_x
			window_y dom_window));

sub _get_window_position {
	my $self = shift;
	my ($win_id) = FindWindowLike('Mozilla::Mechanize');
	my ($x, $y, $width, $height, $bor_w, $scr) = GetWindowPos($win_id);
	$self->window_x($x);
	$self->window_y($y);
}

sub _calculate_element_position {
	my $self = shift;
	my ($top, $left) = (0, 0);
	my $elem = $self->element;
	my $iid = Mozilla::DOM::NSHTMLElement->GetIID;
	while ($elem) {
		$elem = $elem->QueryInterface($iid) or last;
		$top += $elem->GetOffsetTop;
		$left += $elem->GetOffsetLeft;
		$elem = $elem->GetOffsetParent;
	}
	$self->element_top($top);
	$self->element_left($left);
}

sub element_x { return $_[0]->element_left + $_[0]->window_x; }
sub element_y { return $_[0]->element_top + $_[0]->window_y; }

sub new {
	my $self = shift()->SUPER::new(@_);
	$self->_get_window_position;
	$self->_calculate_element_position;
	return $self;
}

sub element_mouse_move {
	my ($self, $by_x, $by_y) = @_;
	my $dwin = $self->dom_window;
	my $iwin = $dwin->QueryInterface(Mozilla::DOM::WindowInternal->GetIID);
	my $left = $self->element_left + $by_x;
	my $top = $self->element_top + $by_y;
	# Once Mozilla::DOM implements it...
	# $dwin->ScrollTo($left, $top);
	Mozilla::SourceViewer::Scroll_To($dwin, $left, $top);
	MoveMouseAbs($left + $self->window_x - $iwin->GetPageXOffset
		, $top + $self->window_y - $iwin->GetPageYOffset);
}

sub window_mouse_move {
	my ($self, $by_x, $by_y) = @_;
	MoveMouseAbs($self->window_x + $by_x, $self->window_y + $by_y);
}

1;
