class WaiverPicks::Create < WaiverPicks::Base
  object :list_position, class: ListPosition
  object :in_player, class: Player
  object :out_player, class: Player, default: -> { list_position.player }

  validate :out_player_in_fpl_team_list
  validate :in_player_unpicked
  validate :same_positions
  validate :maximum_number_of_players_from_team
  validate :duplicate_waiver_picks

  def execute
    waiver_pick = WaiverPick.create(
      fpl_team_list: fpl_team_list,
      out_player: out_player,
      in_player: in_player,
      round: round,
      league: league,
      pick_number: fpl_team_list.waiver_picks.count + 1
    )

    errors.merge!(waiver_pick.errors)
    waiver_pick
  end

  private

  def out_player_in_fpl_team_list
    return if fpl_team_list.players.include?(out_player)
    errors.add(:base, 'You can only trade out players that are part of your team.')
  end

  def in_player_unpicked
    return unless in_player.leagues.include?(league)
    errors.add(:base, 'The player you are trying to trade into your team is owned by another team in your league.')
  end

  def same_positions
    return if out_player.position == in_player.position
    errors.add(:base, 'You can only trade players that have the same positions.')
  end

  def maximum_number_of_players_from_team
    player_arr = fpl_team_list.players.to_a.delete_if { |player| player == out_player }
    team_arr = player_arr.map { |player| player.team_id }
    team_arr << in_player.team_id
    return if team_arr.count(in_player.team_id) <= FplTeam::QUOTAS[:team]
    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{in_player.team.name})."
    )
  end

  def duplicate_waiver_picks
    existing_waiver_pick = fpl_team_list.waiver_picks.find_by(in_player: in_player, out_player: out_player)
    return if existing_waiver_pick.nil?
    errors.add(
      :base,
      "Duplicate waiver pick - (Pick number: #{existing_waiver_pick.pick_number} " \
        "Out: #{existing_waiver_pick.out_player.decorate.name} " \
        "In: #{existing_waiver_pick.in_player.decorate.name})."
    )
  end
end
