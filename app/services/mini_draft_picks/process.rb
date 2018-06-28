class MiniDraftPicks::Process < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  object :fpl_team_list, class: FplTeamList
  object :list_position, class: ListPosition
  object :in_player, class: Player
  object :out_player, class: Player, default: -> { list_position.player }

  validate :round_is_current
  validate :mini_draft_pick_occurring_in_valid_period
  validate :player_in_fpl_team
  validate :mini_draft_pick_round
  validate :fpl_team_turn
  validate :maximum_number_of_players_from_team
  validate :identical_player_and_target_positions
  validate :target_unpicked
  validate :player_in_fpl_team
  validate :authorised_user
  validate :no_consecutive_passes

  run_in_transaction!

  def execute
    mini_draft_pick = MiniDraftPick.create(
      fpl_team: fpl_team,
      out_player: out_player,
      in_player: in_player,
      round: round,
      league: league,
      season: season,
      pick_number: mini_draft_pick_hash[:next_mini_draft_pick_number]
    )
    errors.merge!(mini_draft_pick.errors)

    league.players.delete(out_player)
    league.players << in_player
    errors.merge!(league.errors)

    fpl_team.players.delete(out_player)
    fpl_team.players << in_player
    errors.merge!(fpl_team.errors)

    list_position.update(player: in_player)
    errors.merge!(list_position.errors)

    halt_if_errors!

    if consecutive_passes && current_mini_draft_pick.present?
      MiniDraftPicks::Pass.run(
        league: league,
        fpl_team_list: current_mini_draft_pick.fpl_team.fpl_team_lists.find_by(round: round),
        user: current_mini_draft_pick.fpl_team.user
      )
    end

    MiniDraftPicks::Broadcast.delay.run(
      league: league,
      fpl_team_list: fpl_team_list,
      user: user,
      out_player: out_player,
      in_player: in_player,
    )

    mini_draft_pick
  end

  def mini_draft_pick_hash
    MiniDraftPicks::Hash.run(league: league, fpl_team_list: fpl_team_list, user: user).result
  end

  private

  def consecutive_passes
    mini_draft_pick_hash[:consecutive_passes]
  end

  def round
    fpl_team_list.round
  end

  def season
    mini_draft_pick_hash[:season]
  end

  def current_mini_draft_pick
    mini_draft_pick_hash[:current_mini_draft_pick]
  end

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def player_in_fpl_team
    return if fpl_team.players.include?(out_player)
    errors.add(:base, 'You can only trade out players that are part of your team.')
  end

  def mini_draft_pick_round
    return if round.mini_draft
    errors.add(:base, 'Mini draft picks cannot be performed at this time.')
  end

  def mini_draft_pick_occurring_in_valid_period
    if Time.now > round.deadline_time - 1.day
      errors.add(:base, 'The deadline time for making mini draft picks has passed.')
    end
  end

  def fpl_team_turn
    return if mini_draft_pick_hash[:next_fpl_team] == fpl_team
    errors.add(:base, 'You cannot pick out of turn.')
  end

  def maximum_number_of_players_from_team
    player_arr = fpl_team.players.to_a.delete_if { |player| player == out_player }
    team_arr = player_arr.map(&:team_id)
    team_arr << in_player.team_id
    return if team_arr.count(in_player.team_id) <= FplTeam::QUOTAS[:team]
    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{in_player.team.name})."
    )
  end

  def identical_player_and_target_positions
    return if out_player.position == in_player.position
    errors.add(:base, 'You can only trade players that have the same positions.')
  end

  def authorised_user
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def player_in_fpl_team
    return if fpl_team.players.include?(out_player)
    errors.add(:base, 'You can only trade out players that are part of your team.')
  end

  def target_unpicked
    return unless in_player.leagues.include?(league)
    errors.add(:base, 'The player you are trying to trade into your team is owned by another team in your league.')
  end

  def no_consecutive_passes
    return unless consecutive_passes
    errors.add(:base, 'You have already passed and will not be able to make any more mini draft picks.')
  end

  def fpl_team
    fpl_team_list.fpl_team
  end
end
