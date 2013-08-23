package Scrabble::Form::Game;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default => 'Game');
has_field 'player_one' => (type => 'Select', label_column => 'last_name', required => 1);
has_field 'player_two' => (type => 'Select', label_column => 'last_name', required => 1);
has_field 'player_one_score' => (type => 'Integer', required => 1);
has_field 'player_two_score' => (type => 'Integer', required => 1);
has_field 'submit' => (type => 'Submit', value => 'Submit');

sub validate {
	my $self = shift;
	$self->field('player_two')->add_error("Must be different from Player one!")
		if ($self->field('player_one')->value eq $self->field('player_two')->value);
}

__PACKAGE__->meta->make_immutable;
1;
