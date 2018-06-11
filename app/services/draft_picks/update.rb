class DraftPicks::Update < ApplicationInteraction
  object :league, class: League
  object :draft_pick, class: DraftPick
  boolean :mini_draft, default: false
  object :player, class: Player, default: nil
  object :user, class: User

  object :fpl_team, class: FplTeam, default: -> { draft_pick.fpl_team }

  validate :draft_pick_current
  validate :maximum_number_of_players_from_team, if: :player
  validate :maximum_number_of_players_by_position, if: :player
  validate :maximum_number_of_players, if: :player
  validate :mini_draft_picked, if: :mini_draft
  validate :player_draft_pick_uniqueness, if: :player

  run_in_transaction!

  def execute
    mini_draft ? mini_draft_pick : draft_player

    outcome = Leagues::Activate.run(league: league)
    errors.merge!(outcome.errors)
    DraftPicks::Broadcast.delay.run(league: league, user: user, player: player, mini_draft: mini_draft)

    league
  end

  private

  def draft_player
    draft_pick.update(player: player)
    errors.merge!(draft_pick.errors)

    league.players << player unless league.players.include?(player)
    errors.merge!(league.errors)

    fpl_team.players << player unless fpl_team.players.include?(player)
    errors.merge!(fpl_team.errors)
  end

  def mini_draft_pick
    draft_pick.update(mini_draft: mini_draft)
    errors.merge!(draft_pick.errors)
  end

  def draft_pick_current
    return if league.decorate.current_draft_pick == draft_pick
    return if draft_pick.user == user
    errors.add(:base, 'You cannot pick out of turn.')
  end

  def maximum_number_of_players_from_team
    return if fpl_team.teams.empty?
    return if fpl_team.players.where(team: player.team).count < FplTeam::QUOTAS[:team]
    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player.team.name})."
    )
  end

  def maximum_number_of_players_by_position
    position = player.position
    position_player_number = fpl_team.players.where(position: player.position).count
    return if position_player_number.nil?
    plural_name = position.plural_name

    quota = FplTeam::QUOTAS[plural_name.downcase.to_sym]
    return if position_player_number < quota
    errors.add(:base, "You can't have more than #{quota} #{plural_name} in your team.")
  end

  def maximum_number_of_players
    return unless fpl_team.decorate.all_players_picked?
    errors.add(:base, "You are only allowed #{FplTeam::QUOTAS[:players]} players in a team.")
  end

  def mini_draft_picked
    return unless fpl_team.decorate.mini_draft_picked? && mini_draft
    errors.add(:base, "You have already selected your mini draft pick position.")
  end

  def player_draft_pick_uniqueness
    errors.add(:base, 'This player has already been picked.') if league.players.include?(player)
  end
end
