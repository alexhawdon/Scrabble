package Scrabble::Form::Member;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default => 'Member');
has_field 'first_name' => (required => 1);
has_field 'last_name'  => (required => 1);
has_field 'email' => (minlength => 6, required => 1);
has_field 'phone' => (minlength => 6, required => 1);
has_field 'submit' => (type => 'Submit', value => 'Submit');

__PACKAGE__->meta->make_immutable;
1;
