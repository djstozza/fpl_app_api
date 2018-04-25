class FplTeamListDecorator < ApplicationDecorator
  def list_position_arr
    list_positions
      .order(role: :asc, position_id: :desc)
      .joins(:player, :position, :fpl_team_list)
      .joins('JOIN teams ON teams.id = players.team_id')
      .joins(
        'LEFT JOIN fixtures ON fixtures.round_id = fpl_team_lists.round_id AND ' \
        '(fixtures.team_h_id = teams.id OR fixtures.team_a_id = teams.id)'
      )
      .joins(
        'LEFT JOIN teams AS opponents ON ' \
        '((fixtures.team_h_id = opponents.id AND fixtures.team_a_id = teams.id) OR ' \
        '(fixtures.team_a_id = opponents.id AND fixtures.team_h_id = teams.id))'
      )
      .pluck_to_hash(
        :id,
        :player_id,
        :role,
        :last_name,
        :position_id,
        :singular_name_short,
        :team_id,
        'teams.short_name AS team_short_name',
        :status,
        :total_points,
        :fpl_team_list_id,
        :team_h_id,
        :team_a_id,
        :event_points,
        :news,
        'fixtures.id AS fixture_id',
        'fpl_team_lists.round_id AS round_id',
        'opponents.short_name AS opponent_short_name',
        'opponents.id AS opponent_id',
        :team_h_difficulty,
        :team_a_difficulty,
      ).map do |hash|
        fixture_history =
          Player.find(hash['player_id']).player_fixture_histories.find do |history|
            history['fixture'] == hash['fixture_id']
          end

        if fixture_history
          hash['minutes'] = fixture_history['minutes']
          hash['fixture_points'] = fixture_history['total_points']
        end

        home_fixture = hash['team_id'] == hash['team_h_id']

        hash['leg'] = home_fixture ? 'H' : 'A'

        hash['advantage'] =
          if home_fixture
            hash['team_a_difficulty'] - hash['team_h_difficulty']
          else
            hash['team_h_difficulty'] - hash['team_a_difficulty']
          end

        hash['role'] = hash['role'].gsub(/tarting|ubstitute_/, '').upcase

        hash['status'] = status_class_hash[hash['status'].to_sym]

        hash
      end
  end

  def grouped_list_position_arr
    list_position_arr
      .group_by { |h| h['role'] }
      .each_with_object({}) { |(k, v), h| h[k] = v.group_by { |g| g['singular_name_short'] } }
  end

  def waiver_picks_arr
    waiver_picks.order(:pick_number).joins(
      'JOIN players AS in_players ON waiver_picks.in_player_id = in_players.id'
    ).joins(
      'JOIN players AS out_players ON waiver_picks.out_player_id = out_players.id'
    ).joins(
      'JOIN teams AS in_teams ON in_players.team_id = in_teams.id'
    ).joins(
      'JOIN teams AS out_teams ON out_players.team_id = out_teams.id'
    ).joins(
      'JOIN positions ON in_players.position_id = positions.id'
    ).pluck_to_hash(
      :id,
      :pick_number,
      :status,
      :singular_name_short,
      :in_player_id,
      'in_players.first_name as in_first_name',
      'in_players.last_name as in_last_name',
      'in_teams.short_name as in_team_short_name',
      :out_player_id,
      'out_players.first_name as out_first_name',
      'out_players.last_name as out_last_name',
      'out_teams.short_name as out_team_short_name'
    )
  end

  def status
    if round.mini_draft && Time.now < round.deadline_time - 1.day
      'mini_draft'
    elsif Time.now < round.deadline_time - 1.day && round.id != Round.first.id
      'waiver'
    elsif Time.now < round.deadline_time
      'trade'
    elsif round.deadline_time < Time.now && Time.now < round.deadline_time + round.deadline_time_game_offset
      'pre_game'
    else
      'started'
    end
  end

  private

  def status_class_hash
    {
      a: 'fa fa-check-circle',
      d: 'fa fa-question-circle',
      i: 'fa fa-ambulance',
      n: 'fa fa-times-circle',
      s: 'fa fa-gavel',
      u: 'fa fa-times-circle',
    }
  end
end
