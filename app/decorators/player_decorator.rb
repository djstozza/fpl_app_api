class PlayerDecorator < ApplicationDecorator
  def name
    "#{first_name} #{last_name}"
  end

  def players_hash
    joins(:position)
      .joins(
        "LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS (players.player_fixture_histories) fixture_histories ON " \
        "(fixture_histories ->> 'element')::INT = players.id"
      )
      .group('players.id', 'singular_name_short')
      .distinct
      .pluck_to_hash(
        :id,
        :first_name,
        :last_name,
        :photo,
        :status,
        :code,
        :news,
        :chance_of_playing_next_round,
        :chance_of_playing_this_round,
        :in_dreamteam,
        :dreamteam_count,
        :form,
        "SUM((fixture_histories ->> 'total_points')::INT) AS total_points",
        :event_points,
        :points_per_game,
        "SUM((fixture_histories ->> 'minutes')::INT) AS minutes",
        "SUM((fixture_histories ->> 'goals_scored')::INT) AS goals_scored",
        "SUM((fixture_histories ->> 'assists')::INT) AS assists",
        "SUM((fixture_histories ->> 'clean_sheets')::INT) AS clean_sheets",
        "SUM((fixture_histories ->> 'goals_conceded')::INT) AS goals_conceded",
        "SUM((fixture_histories ->> 'own_goals')::INT) AS own_goals",
        "SUM((fixture_histories ->> 'penalties_saved')::INT) AS penalties_saved",
        "SUM((fixture_histories ->> 'penalties_missed')::INT) AS penalties_missed",
        "SUM((fixture_histories ->> 'yellow_cards')::INT) AS yellow_cards",
        "SUM((fixture_histories ->> 'red_cards')::INT) AS red_cards",
        "SUM((fixture_histories ->> 'saves')::INT) AS saves",
        "SUM((fixture_histories ->> 'bonus')::INT) AS bonus",
        "SUM((fixture_histories ->> 'bps')::INT) AS bps",
        :influence,
        :creativity,
        :threat,
        :ict_index,
        :open_play_crosses,
        "SUM((fixture_histories ->> 'big_chances_created')::INT) AS big_chances_created",
        "SUM((fixture_histories ->> 'clearances_blocks_interceptions')::INT) AS clearances_blocks_interceptions",
        "SUM((fixture_histories ->> 'recoveries')::INT) AS recoveries",
        "SUM((fixture_histories ->> 'key_passes')::INT) AS key_passes",
        "SUM((fixture_histories ->> 'winning_goals')::INT) AS winning_goals",
        "SUM((fixture_histories ->> 'tackles')::INT) AS tackles",
        "SUM((fixture_histories ->> 'dribbles')::INT) AS dribbles",
        "SUM((fixture_histories ->> 'fouls')::INT) AS fouls",
        "SUM((fixture_histories ->> 'errors_leading_to_goal')::INT) AS errors_leading_to_goal",
        "SUM((fixture_histories ->> 'offside')::INT) AS offside",
        :position_id,
        :team_id,
        :singular_name_short,
      ).map do |hash|
        hash['status'] = status_class_hash[hash['status'].to_sym]
        hash
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
