class FplTeamLists::Score < ApplicationInteraction
  object :fpl_team_list, class: FplTeamList

  def execute
    process_field_substitutions
    process_goalkeeper_substitution
    fpl_team_list.update(total_score: score)
    errors.merge!(fpl_team_list.errors)
  end

  private

  def list_positions
    fpl_team_list
      .list_positions
      .joins(:player, :fpl_team_list)
      .joins('JOIN teams ON teams.id = players.team_id')
      .joins('JOIN positions ON players.position_id = positions.id')
      .joins(
        'LEFT JOIN fixtures ON fixtures.round_id = fpl_team_lists.round_id AND ' \
        '(fixtures.team_h_id = teams.id OR fixtures.team_a_id = teams.id)'
      )
      .joins(
        "LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS (players.player_fixture_histories) fixture_history ON " \
        "(fixture_history ->> 'fixture')::INT = fixtures.id AND " \
        "(((fixture_history ->> 'was_home')::BOOLEAN IS TRUE AND fixtures.team_h_id = teams.id) OR " \
        "((fixture_history ->> 'was_home')::BOOLEAN IS FALSE AND fixtures.team_a_id = teams.id))"
      )
  end

  def starting_field_positions
    list_positions.starting.field_players
  end

  def goalkeepers
    list_positions.goalkeepers
  end

  def counted_starting_field_positions
    counted(starting_field_positions)
  end

  def uncounted_starting_field_positions
    starting_field_positions
      .where.not(id: counted_starting_field_positions.pluck(:id))
      .order('fixtures.kickoff_time', :id)
      .uniq
  end

  def substitute_field_positions
    counted(list_positions.field_players.substitutes).uniq
  end

  def process_field_substitutions
    substitutes = substitute_field_positions
    uncounted = uncounted_starting_field_positions

    return if substitutes.blank? || uncounted.blank?

    uncounted.each do |list_position|
      substitutes.each do |substitute|
        next unless valid_substitution(list_position, substitute) && list_position.starting?

        list_position.update(role: substitute.role)
        errors.merge!(list_position.errors)

        substitute.update(role: 'starting')
        errors.merge!(substitute.errors)
      end
    end
  end

  def process_goalkeeper_substitution
    starting_goalkeeper = goalkeepers.starting
    substitute_goalkeeper = goalkeepers.substitutes
    return if counted(substitute_goalkeeper).blank? || counted(starting_goalkeeper).present?

    substitute_goalkeeper.first.update(role: 'starting')
    errors.merge!(substitute_goalkeeper.errors)

    starting_goalkeeper.first.update(role: 'substitute_gkp')
    errors.merge!(starting_goalkeeper.errors)
  end

  def valid_substitution(list_position, substitute)
    return if substitute.starting? && !list_position.starting?

    arr = substitute_starting_field_positions_arr(list_position, substitute)

    arr.count <= 10 && arr.count('FWD') >= 1 && arr.count('MID') >= 2 && arr.count('DEF') >= 3
  end

  def substitute_starting_field_positions_arr(list_position, substitute)
    arr = starting_field_positions.where.not(id: list_position.id).pluck_to_hash(:singular_name_short, :id).uniq
    arr << { singular_name_short: substitute.position.singular_name_short, id: substitute.id }
    arr = arr.pluck(:singular_name_short)
  end

  def counted(instance)
    instance.where(
      "fixtures.finished IS FALSE OR (fixtures.finished IS TRUE AND " \
      "(fixture_history ->> 'minutes')::INT > ?)",
      0,
    )
  end

  def fixture_points_bonus_calculator(hash)
    return if hash['finished'] || !hash['started']

    hash['fixture_points'] += 3 if hash['bps'].first['element'] == hash['player_id']
    hash['fixture_points'] += 2 if hash['bps'].second['element'] == hash['player_id']
    hash['fixture_points'] += 1 if hash['bps'].third['element'] == hash['player_id']
  end

  def fixture_points_arr
    list_positions.starting.pluck_to_hash(
      :player_id,
      "(fixture_history ->> 'total_points')::INT AS fixture_points",
      "(fixtures.stats -> 'bps') AS bps",
      :finished,
      :started,
    ).each do |hash|
      fixture_points_bonus_calculator(hash) if hash['fixture_points']
    end
  end

  def score
    fixture_points_arr.inject(0) { |sum, hash| hash['fixture_points'].present? ? sum + hash['fixture_points'] : sum }
  end
end
