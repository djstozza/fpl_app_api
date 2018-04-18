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

        hash['role'] =
          if hash['role'] == 'starting'
            'S'
          else
            hash['role'].gsub('ubstitute_', '').upcase
          end

        hash
      end
  end

  def grouped_list_position_arr
    list_position_arr
      .group_by { |h| h['role'] }
      .each_with_object({}) { |(k, v), h| h[k] = v.group_by { |g| g['singular_name_short'] } }
  end
end
