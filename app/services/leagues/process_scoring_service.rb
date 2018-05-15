class Leagues::ProcessScoringService < ActiveInteraction::Base
  object :league, class: League
  object :round, class: Round

  def execute
    ActiveRecord::Base.transaction do
      league.fpl_teams.each do |fpl_team|
        fpl_team_list = fpl_team.fpl_team_lists.find_by(round: round)
        @line_up = fpl_team_list.list_positions
        substitute_players if counted_list_positions.count < 10
        starting_gkp = @line_up.starting.goalkeepers.first.player
        substitute_gkp = @line_up.find_by(role: 'substitute_gkp').player
        if minutes_parser(starting_gkp).zero? && !minutes_parser(substitute_gkp).zero?
          @line_up.find_by(player: starting_gkp).update(role: 'substitute_gkp')
          @line_up.find_by(player: substitute_gkp).update(role: 'starting')
        end
        scores_arr = fpl_team_list.list_positions.starting.map do |list_position|
          player_score(list_position.player)
        end
        fpl_team_list.update(total_score: scores_arr.inject(0) { |sum, x| sum + x })
        fpl_team.update(total_score: fpl_team.fpl_team_lists.pluck(:total_score).inject(0) { |sum, x| sum + x })
      end
    end
  end

  private

  def player_fixture_history(player)
    player.player_fixture_histories.select { |pfh| pfh['round'] == round.id }
  end

  def kickoff_time_parser(player)
    pfh = player_fixture_history(player)
    return '' if pfh.blank?
    pfh.sort { |a, b| a['kickoff_time'] <=> b['kickoff_time'] }.first['kickoff_time']
  end

  def player_score(player)
    pfh = player_fixture_history(player)
    return 0 if pfh.blank?
    pfh.inject(0) { |sum, x| sum +  x['total_points'].to_i }
  end

  def minutes_parser(player)
    pfh = player_fixture_history(player)
    return 0 if pfh.blank?
    pfh.inject(0) { |sum, x| sum + x['minutes'].to_i }
  end

  def starting_field_line_up
    @line_up.field_players.starting.sort do |a, b|
      kickoff_time_parser(a.player) <=> kickoff_time_parser(b.player)
    end
  end

  def counted_list_positions
    starting_field_line_up.delete_if { |list_position| minutes_parser(list_position.player).to_i.zero? }
  end

  def substitute_arr
    @line_up.field_players.substitutes.to_a.delete_if do |list_position|
      minutes_parser(list_position.player).zero?
    end
  end

  def starting_position_count(starting_lineup_arr, position_name)
    starting_lineup_arr.select { |list_position| list_position.position.singular_name == position_name }.count
  end

  def substitute_players
    return if substitute_arr.blank?

    starting_field_line_up.select { |list_position| minutes_parser(list_position.player).zero? }.each do |list_position|
      substitute_arr.each do |substitute|
        next unless valid_substitution(list_position, substitute) && list_position.starting?
        list_position.update(role: substitute.role)
        substitute.update(role: 'starting')
      end
    end
  end

  def valid_substitution(list_position, substitute)
    arr = starting_field_line_up.delete_if { |position| position == list_position }
    arr << substitute
    return if arr.count > 10
    return if starting_position_count(arr, 'Forward') < 1
    return if starting_position_count(arr, 'Midfielder') < 2
    return if starting_position_count(arr, 'Defender') < 3
    true
  end
end
