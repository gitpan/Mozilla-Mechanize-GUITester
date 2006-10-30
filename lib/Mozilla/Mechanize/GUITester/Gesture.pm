use strict;
use warnings FATAL => 'all';

package Mozilla::Mechanize::GUITester::Gesture;
use base 'Class::Accessor';
use Mozilla::DOM;
use X11::GUITest qw(FindWindowLike GetWindowPos MoveMouseAbs);

__PACKAGE__->mk_accessors(qw(element element_x element_y window_x
			window_y));

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
	$self->element_x($left + $self->window_x);
	$self->element_y($top + $self->window_y);
}

sub new {
	my $self = shift()->SUPER::new(@_);
	$self->_get_window_position;
	$self->_calculate_element_position;
	return $self;
}

sub element_mouse_move {
	my ($self, $by_x, $by_y) = @_;
	MoveMouseAbs($self->element_x + $by_x, $self->element_y + $by_y);
}

sub window_mouse_move {
	my ($self, $by_x, $by_y) = @_;
	MoveMouseAbs($self->window_x + $by_x, $self->window_y + $by_y);
}

1;
