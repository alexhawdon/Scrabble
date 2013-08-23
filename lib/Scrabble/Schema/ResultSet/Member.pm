package Scrabble::Schema::ResultSet::Member;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub ranked_members {
	my $self = @_;
	return $self->search(
		{ games_played => "> 9" },
		order_by       => { -desc => "average_score" },
	);
}

1;