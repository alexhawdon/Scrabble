package Scrabble::Controller::Root;
use Moose;
use namespace::autoclean;
use Scrabble::Form::Member;
use Scrabble::Form::Game;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

Scrabble::Controller::Root - Root Controller for Scrabble

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

## Form processing
sub member_form {
    my ($self, $c, $member) = @_;

    my $form = Scrabble::Form::Member->new;
    $c->stash( form => $form );
    $form->process(item => $member, params => $c->req->params );
    return unless $form->validated;
    $c->response->redirect($c->uri_for('/members/show/' . $member->id,
        { mid => $c->set_status_msg("Member created / updated")}));
}

sub game_form {
    my ($self, $c, $game) = @_;
    my $form = Scrabble::Form::Game->new;
    $c->stash(form => $form);
    $form->process(item => $game, params => $c->req->params);
    return unless $form->validated;
    $game->update_players();
    $c->response->redirect($c->uri_for('/members/all/',
                           { mid => $c->set_status_msg("New game added.")}));
}

## Controller Methods

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	return $c->response->redirect($c->uri_for('members'));
}

sub members_base : Chained('/') PathPart('members') CaptureArgs(0) {
    my ($self, $c) = @_;
    my @members = $c->model('DB::Member')->search({}, 
            { order_by => ["last_name", "first_name"]});

    $c->stash(
    	template 		=> "members.tt2",
    	members 		=>	\@members,
    	selected_member => $members[0],
	);
}

sub all_members : Chained('members_base') PathPart('all') Args(0) {
    my ($self, $c) = @_;
    # Continues at end function
}

sub specific_member : Chained('members_base') PathPart('show') Args(1) {
    my ($self, $c, $member_id) = @_;

    my $selected_member = $c->model('DB::Member')->find({id => $member_id}) ||
        $c->detach('default');

    $c->stash(
        selected_member => $selected_member,
    );
}

sub create_or_edit_member : Chained('members_base') PathPart('update') {
    my ($self, $c, $member_id) = @_;
    my $member;
    if ($member_id) {
        # Edit
        $member = $c->model('DB::Member')->find({id => $member_id}) ||
            $c->detach('default');
        $self->member_form($c, $member);
    } else {
        # Create
        $member = $c->model('DB::Member')->new_result({});
        $self->member_form($c, $member);
    }
    $c->stash(
        template => 'create_or_edit_member.tt2',
        selected_member => $member,
    );
}

sub add_game :Chained('members_base') :PathPart('add_game') {
    my ($self, $c) = @_;
    my $game = $c->model('DB::Game')->new_result({});
    $self->game_form($c, $game);
    $c->stash( 
        template => "add_game.tt2",
        selected_member => undef
    );
}

sub leaderboard :Chained('members_base') :PathPart('leaderboard') {
    my ($self, $c) = @_;
    $c->stash(
        leaderboard => [
            $c->model('DB::Member')->search(
                {games_played => {'>' => 9}},
                {order_by => { -desc => 'average_score'}}
            )],
        template => "leaderboard.tt2",
        selected_member => undef
    );
    
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
	my ($self, $c) = @_;
    $c->load_status_msgs;
	$c->response->header('Cache-Control' => 'no-cache');
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
