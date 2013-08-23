use utf8;
package Scrabble::Schema::Result::Game;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Scrabble::Schema::Result::Game

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

=head1 TABLE: C<game>

=cut

__PACKAGE__->table("game");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 played_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 player_one

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 player_two

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 player_one_score

  data_type: 'integer'
  is_nullable: 0

=head2 player_two_score

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "played_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "player_one",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "player_two",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "player_one_score",
  { data_type => "integer", is_nullable => 0 },
  "player_two_score",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 members

Type: has_many

Related object: L<Scrabble::Schema::Result::Member>

=cut

__PACKAGE__->has_many(
  "members",
  "Scrabble::Schema::Result::Member",
  { "foreign.best_game" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 player_one

Type: belongs_to

Related object: L<Scrabble::Schema::Result::Member>

=cut

__PACKAGE__->belongs_to(
  "player_one",
  "Scrabble::Schema::Result::Member",
  { id => "player_one" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 player_two

Type: belongs_to

Related object: L<Scrabble::Schema::Result::Member>

=cut

__PACKAGE__->belongs_to(
  "player_two",
  "Scrabble::Schema::Result::Member",
  { id => "player_two" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-22 12:13:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P2BzPQni+zvZVQrkjYuLFQ

__PACKAGE__->add_columns(
  "played_date",
  { data_type => 'timestamp', set_on_create => 1},
);

sub get_score_for_id {
  my ($self, $member_id) = @_;
  if ($self->player_one->id == $member_id) {
    return $self->player_one_score;
  } elsif ($self->player_two->id == $member_id) {
    return $self->player_two_score;
  }
  return undef;
}

sub get_opponent_score_for_id {
  my ($self, $member_id) = @_;
  if ($self->player_one->id == $member_id) {
    return $self->player_two_score;
  } elsif ($self->player_two->id == $member_id) {
    return $self->player_one_score;
  }
  return undef;
}

sub get_opponent_name {
  my ($self, $member_id) = @_;
  if ($self->player_one->id == $member_id) {
    return $self->player_two->full_name;
  } elsif ($self->player_two->id == $member_id) {
    return $self->player_one->full_name;
  }
  return undef;
}

sub update_players {
  # Updates related player stats - run ONCE per game.
  my ($self) = @_;

  my $player_one = $self->player_one;

  my $player_two = $self->player_two;
  
  $player_one->set_column(cumulative_score => 
        $player_one->get_column("cumulative_score") + $self->player_one_score);
  $player_two->set_column(cumulative_score => 
      $player_two->get_column("cumulative_score") + $self->player_two_score);
  $player_one->set_column(games_played =>
    $player_one->get_column("games_played") + 1);
  $player_two->set_column(games_played =>
    $player_two->get_column("games_played") + 1);
  $player_one->set_column('average_score', 
        int(($player_one->get_column('cumulative_score') / $player_one->get_column('games_played'))+0.5));
  $player_two->set_column('average_score', 
        int(($player_two->get_column('cumulative_score') / $player_two->get_column('games_played'))+0.5));

  if (!$player_one->best_game ||
    $player_one->best_game->get_score_for_id($self->player_one->id) < $self->player_one_score) {

    $player_one->set_column(best_game => $self->id);
  }

  if (!$player_two->best_game ||
    $player_two->best_game->get_score_for_id($self->player_two->id) < $self->player_two_score) {

    $player_two->set_column(best_game => $self->id);
  }

  if ($self->player_one_score > $self->player_two_score) {
    $player_one->set_column(games_won => 
      $player_one->get_column("games_won") + 1);
    $player_two->set_column(games_lost => 
      $player_two->get_column("games_lost") + 1);
  } elsif ($self->player_two_score > $self->player_one_score) {
    $player_two->set_column(games_won => 
      $player_two->get_column("games_won") + 1);
    $player_one->set_column(games_lost => 
      $player_one->get_column("games_lost") + 1);
  } else {
    $player_one->set_column(games_drawn => 
      $player_one->get_column("games_drawn") + 1);
    $player_two->set_column(games_drawn => 
      $player_two->get_column("games_drawn") + 1);
  }

  $player_one->update;
  $player_two->update;

  return 1;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
