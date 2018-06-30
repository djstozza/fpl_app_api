class FplTeamLists::ProcessTrade < ApplicationInteraction
  object :user, class: User
  object :list_position, class: ListPosition
  object :in_player, class: Player

  delegate :fpl_team_list, to: :list_position
  delegate :player, to: :list_position, prefix: :out
  delegate :fpl_team, :round, to: :fpl_team_list
  delegate :league, to: :fpl_team

  validate :authorised_user
  validate :out_player_in_fpl_team
  validate :in_player_unpicked
  validate :round_is_current
  validate :trade_occurring_in_valid_period
  validate :same_positions
  validate :maximum_number_of_players_from_team

  run_in_transaction!

  def execute
    fpl_team.players.delete(out_player)
    fpl_team.players << in_player
    errors.merge!(fpl_team.errors)

    league.players.delete(out_player)
    league.players << in_player
    errors.merge!(league.errors)

    list_position.assign_attributes(player: in_player)
    list_position.save
    errors.merge!(list_position.errors)

    list_position
  end

  def fpl_team_list_hash
    FplTeamLists::Hash.run(
      fpl_team_list: fpl_team_list,
      user: user,
      show_list_positions: true,
      show_waiver_picks: true,
      user_owns_fpl_team: fpl_team.user == user,
    ).result
  end

  private

  def authorised_user
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def out_player_in_fpl_team
    return if fpl_team.players.include?(out_player)
    errors.add(:base, 'You can only trade out players that are part of your team.')
  end

  def in_player_unpicked
    return unless league.players.include?(in_player)
    errors.add(:base, 'The player you are trying to trade into your team is owned by another team in your league.')
  end

  def trade_occurring_in_valid_period
    if Time.now < round.deadline_time - 1.day && round.id != Round.first.id
      errors.add(:base, 'You cannot trade players until the waiver cutoff time has passed.')
    elsif Time.now > round.deadline_time
      errors.add(:base, 'The deadline time for making trades has passed.')
    end
  end

  def same_positions
    return if out_player.position == in_player.position
    errors.add(:base, 'You can only trade players that have the same positions.')
  end

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def maximum_number_of_players_from_team
    player_arr = fpl_team.players.to_a.delete_if { |player| player == out_player }
    team_arr = player_arr.map { |player| player.team_id }
    team_arr << in_player.team_id
    return if team_arr.count(in_player.team_id) <= FplTeam::QUOTAS[:team]
    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{in_player.team.name})."
    )
  end
end
