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

  private

  def list_positions
    fpl_team_list.list_positions.order(role: :asc, position_id: :desc)
  end

  def invalid_substitution?(out_lp, in_lp)
    position_arr = list_positions.starting.where.not(player_id: out_lp.player_id).pluck(:position_id)
    position_arr << in_lp.position_id
    position_arr = position_arr.group_by(&:itself)
    position_arr[position_hash['Forward']].blank? ||
      position_arr[position_hash['Midfielder']].count < 2 ||
      position_arr[position_hash['Defender']].count < 3
  end

  def position_hash
    @position_hash ||= Position.pluck(:singular_name, :id).to_h
  end
end
