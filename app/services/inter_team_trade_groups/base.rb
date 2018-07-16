class InterTeamTradeGroups::Base < ApplicationInteraction
  object :fpl_team_list, class: FplTeamList
  object :user, class: User

  delegate :fpl_team, :round, to: :fpl_team_list
  delegate :league, to: :fpl_team

  delegate :in_fpl_team_list, :out_fpl_team_list, to: :inter_team_trade_group

  delegate :fpl_team, to: :out_fpl_team_list, prefix: :out
  delegate :fpl_team, to: :in_fpl_team_list, prefix: :in

  validate :round_is_current
  validate :trade_occurring_in_valid_period

  attr_reader :success_message

  run_in_transaction!

  def in_player
    in_list_position.player
  end

  def out_player
    out_list_position.player
  end

  def fpl_team_list_hash
    FplTeamLists::Hash.run(
      fpl_team_list: fpl_team_list,
      user: user,
      show_trade_groups: true,
      user_owns_fpl_team: fpl_team.user == user,
    ).result
  end

  private

  def authorised_user_out_fpl_team
    return if out_fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def in_fpl_team_in_league
    return if in_fpl_team.league == league
    errors.add(:base, "#{in_fpl_team.name} is not part of your league.")
  end

  def authorised_user_in_fpl_team
    return if in_fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def out_player_in_fpl_team
    return if out_fpl_team.players.include?(out_player)
    errors.add(:base, 'You can only trade out players that are part of your team.')
  end

  def in_player_in_fpl_team
    return if in_fpl_team.players.include?(in_player)
    errors.add(:base, 'You can only propose trades with players that are in that fpl team.')
  end

  def identical_player_and_target_positions
    return if out_player.position == in_player.position
    errors.add(:base, 'You can only trade players that have the same positions.')
  end

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def trade_occurring_in_valid_period
    if Time.now > round.deadline_time
      errors.add(:base, 'The deadline time for making trades this round has passed.')
    end
  end

  def unique_in_player_in_group
    if inter_team_trade_group.in_players.include?(in_player)
      errors.add(:base, "A trade already exists with this player in the trade group: #{in_player.decorate.name}.")
    end
  end

  def unique_out_player_in_group
    if inter_team_trade_group.out_players.include?(out_player)
      errors.add(:base, "A trade already exists with this player in the trade group: #{out_player.decorate.name}.")
    end
  end

  def valid_team_quota_out_fpl_team
    out_players = out_fpl_team.players - (inter_team_trade_group.out_players.to_a << out_player)
    in_players = inter_team_trade_group.in_players.to_a << in_player

    team_arr = out_players.map(&:team) + in_players.map(&:team)
    team = team_arr.detect { |id| team_arr.count(id) > FplTeam::QUOTAS[:team] }
    return unless team

    errors.add(:base, "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{team.name}).")
  end

  def valid_team_quota_in_fpl_team
    in_players = in_fpl_team.players - (inter_team_trade_group.in_players.to_a << in_player)
    out_players = inter_team_trade_group.out_players.to_a << out_player

    team_arr = in_players.map(&:team) + out_players.map(&:team)
    team = team_arr.detect { |id| team_arr.count(id) > FplTeam::QUOTAS[:team] }
    return unless team

    errors.add(
      :base,
      "#{in_fpl_team.name} can't have more than #{FplTeam::QUOTAS[:team]} players from the same team " \
        "(#{team.name})."
    )
  end

  def out_players_in_fpl_team
    remainder = inter_team_trade_group.out_players - out_fpl_team.players
    return if remainder.empty?
    errors.add(:base, "Not all the players in this proposed trade are in the team (#{out_fpl_team.name}).")
  end

  def in_players_in_fpl_team
    remainder = inter_team_trade_group.in_players - in_fpl_team.players
    return if remainder.empty?
    errors.add(:base, "Not all the players in this proposed trade are in the team (#{in_fpl_team.name}).")
  end

  def no_duplicate_trades
    duplicates_present =
      InterTeamTradeGroup
        .where.not(status: ['pending', 'declined'])
        .where(out_fpl_team_list: out_fpl_team_list, in_fpl_team_list: in_fpl_team_list)
        .any? do |trade_group|
          trade_group.in_players == inter_team_trade_group.in_players &&
          trade_group.out_players == inter_team_trade_group.out_players
        end

    return unless duplicates_present
    errors.add(:base, 'You have already proposed this trade.')
  end
end
