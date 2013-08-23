use utf8;
package Scrabble::Schema::Result::Member;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Scrabble::Schema::Result::Member

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<member>

=cut

__PACKAGE__->table("member");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 first_name

  data_type: 'text'
  is_nullable: 0

=head2 last_name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 0

=head2 joined

  data_type: 'date'
  default_value: current_timestamp
  is_nullable: 0

=head2 games_played

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 cumulative_score

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 average_score

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 best_game

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 games_won

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 games_drawn

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 games_lost

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "first_name",
  { data_type => "text", is_nullable => 0 },
  "last_name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 0 },
  "joined",
  {
    data_type     => "date",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "games_played",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "cumulative_score",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "average_score",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "best_game",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "games_won",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "games_drawn",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "games_lost",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 best_game

Type: belongs_to

Related object: L<Scrabble::Schema::Result::Game>

=cut

__PACKAGE__->belongs_to(
  "best_game",
  "Scrabble::Schema::Result::Game",
  { id => "best_game" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 game_player_ones

Type: has_many

Related object: L<Scrabble::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
  "game_player_ones",
  "Scrabble::Schema::Result::Game",
  { "foreign.player_one" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 game_player_twos

Type: has_many

Related object: L<Scrabble::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
  "game_player_twos",
  "Scrabble::Schema::Result::Game",
  { "foreign.player_two" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-22 12:13:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mjjVQ+7fgDUp4qpNeiYaBA

__PACKAGE__->add_columns(
  "joined",
  { data_type => 'timestamp', set_on_create => 1 },
);

sub get_games {
  my ($self) = @_;
  return $self->result_source->schema->resultset('Game')->search(
    [{player_one => $self->id}, {player_two => $self->id}],
    {order_by => { -desc => 'played_date'}}
  );
}

sub full_name {
  my ($self) = @_;
  return $self->first_name . " " . $self->last_name;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
