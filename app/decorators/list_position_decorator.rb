class ListPositionDecorator < ApplicationDecorator
  def substitute_options
    options =
      if list_positions.goalkeepers.include?(__getobj__)
        list_positions.goalkeepers.where.not(player_id: player_id)
      elsif starting?
        list_positions
          .field_players
          .substitutes
          .to_a
          .delete_if { |list_position| invalid_substitution?(self, list_position) }
      else
        list_positions
          .field_players
          .where.not(player_id: player_id)
          .to_a
          .delete_if { |list_position| invalid_substitution?(list_position, self) }
      end
    options.pluck(:player_id)
  end

  # Not sure whether I'll have to use this or whether event_points will be sufficient
  def scoring_hash
    pfh = player_fixture_history
    {
      id: id,
      role: role,
      position_id: position_id,
      player_id: player_id,
      status: player.status,
      minutes: pfh.nil? ? 0 : pfh['minutes'],
      points: pfh.nil? ? 0 : pfh['total_points'],
      team_id: player.team_id
    }
  end

  private

  def list_positions
    fpl_team_list.list_positions.order(role: :asc, position_id: :desc)
  end

  def invalid_substitution?(out_lp, in_lp)
    position_arr = list_positions.starting.where.not(player_id: out_lp.player_id).pluck(:position_id)
    position_arr << in_lp.position_id
    position_arr = position_arr.group_by(&:itself)
    print "#{position_arr[position_hash['Forward']]} #{position_arr[position_hash['Midfielder']]} #{position_arr[position_hash['Defender']]}"
    position_arr[position_hash['Forward']].blank? ||
      position_arr[position_hash['Midfielder']].count < 2 ||
      position_arr[position_hash['Defender']].count < 3
  end

  def position_hash
    @position_hash ||= Position.pluck(:singular_name, :id).to_h
  end

  def player_fixture_history
    player.player_fixture_histories.find { |pfh| pfh['round'] == fpl_team_list.round_id }
  end

  def minutes
    player_fixture_history ? player_fixture_history['minutes'] : 0
  end

  def points
    player_fixture_history ? player_fixture_history['total_points'] : 0
  end
end
