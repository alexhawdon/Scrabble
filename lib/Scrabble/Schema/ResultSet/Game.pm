package Scrabble::Schema::ResultSet::Game;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub add_game {
	my ($self, $player_one_id, $player_two_id, 
		$player_one_score, $player_two_score) = @_;
	
	return undef if $player_one_id == $player_two_id;
	
	my $player_one = $self->result_source->schema->resultset('Member')->find(
		{ id => $player_one_id }) || return undef;

	my $player_two = $self->result_source->schema->resultset('Member')->find(
		{ id => $player_two_id }) || return undef;
	
	my $game = $self->create({
		player_one 	   => $player_one,
		player_two 	   => $player_two,
		player_one_score => $player_one_score,
		player_two_score => $player_two_score,
	}) || return undef;

	$player_one->set_column(cumulative_score => 
      	$player_one->get_column("cumulative_score") + $player_one_score);
	$player_two->set_column(cumulative_score => 
	    $player_two->get_column("cumulative_score") + $player_two_score);
	$player_one->set_column(games_played =>
		$player_one->get_column("games_played") + 1);
	$player_two->set_column(games_played =>
		$player_two->get_column("games_played") + 1);
	$player_one->set_column('average_score', 
    		int(($player_one->get_column('cumulative_score') / $player_one->get_column('games_played'))+0.5));
	$player_two->set_column('average_score', 
    		int(($player_two->get_column('cumulative_score') / $player_two->get_column('games_played'))+0.5));

	if (!$player_one->best_game ||
		$player_one->best_game->get_score_for_id($player_one_id) < $player_one_score) {

		$player_one->set_column(best_game => $game->id);
	}

	if (!$player_two->best_game ||
		$player_two->best_game->get_score_for_id($player_two_id) < $player_two_score) {

		$player_two->set_column(best_game => $game->id);
	}

	if ($player_one_score > $player_two_score) {
		$player_one->set_column(games_won => 
			$player_one->get_column("games_won") + 1);
		$player_two->set_column(games_lost => 
			$player_two->get_column("games_lost") + 1);
	} elsif ($player_two_score > $player_one_score) {
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

1;