use strict;
use warnings FATAL => 'all';

package Mozilla::Mechanize::GUITester::Gesture;
use base 'Class::Accessor';
use Mozilla::DOM;
use X11::GUITest qw(GetWindowPos MoveMouseAbs);
use Mozilla::DOM::ComputedStyle;

__PACKAGE__->mk_accessors(qw(element element_top element_left window_x
			zoom window_y dom_window window_id));

sub _D { print STDERR "# $_[0]\n" if $ENV{MMG_DEBUG}; }

sub _get_window_position {
	my $self = shift;
	my ($x, $y) = GetWindowPos($self->window_id);
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
		$top += $elem->GetOffsetTop * $self->zoom;
		$left += $elem->GetOffsetLeft * $self->zoom;
		$elem = $elem->GetOffsetParent;
	}
	$self->element_top($top);
	$self->element_left($left);
}

sub _adjust_scrolls {
	my ($self, $by_x, $by_y) = @_;
	my $iid = Mozilla::DOM::NSHTMLElement->GetIID;
	my $elem = $self->element->QueryInterface(Mozilla::DOM::Node->GetIID);
	my $pos = Get_Computed_Style_Property($self->dom_window, $elem
				, "position");

	$elem->QueryInterface($iid)->ScrollIntoView(1);
	my ($left, $top) = ($self->element_left, $self->element_top);
	_D("begin _adjust_scrolls $left $top");
	goto OUT if ($pos eq 'fixed');
	while ($elem = $elem->GetParentNode) {
		goto OUT if Get_Computed_Style_Property($self->dom_window, $elem
				, "position") eq 'fixed';

		my $e;
		eval { $e = $elem->QueryInterface($iid); };
		next unless $e;

		# Because of the rounding we may get scroll coordinates
		# greater than needed. Be on the safe side - decrement by 1.
		# It cannot be less than 0 anyhow ...
		# However it is really untestable :(
		$e->SetScrollTop($e->GetScrollTop + $by_y - 1)
			if $e->GetScrollTop;
		$e->SetScrollLeft($e->GetScrollLeft + $by_x - 1)
			if $e->GetScrollLeft;

		_D("adjusting scrolls $left $top " . $e->GetScrollLeft
			. " " . $e->GetScrollTop);
		$top -= $e->GetScrollTop * $self->zoom;
		$left -= $e->GetScrollLeft * $self->zoom;
	}
OUT:
	return ($left + $by_x, $top + $by_y);
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
	_D("element_mouse_move $by_x $by_y");
	my ($left, $top) = $self->_adjust_scrolls($by_x, $by_y);
	_D("after _adjust_scrolls $left $top");
	MoveMouseAbs($left + $self->window_x, $top + $self->window_y);
}

sub window_mouse_move {
	my ($self, $by_x, $by_y) = @_;
	MoveMouseAbs($self->window_x + $by_x, $self->window_y + $by_y);
}

1;
