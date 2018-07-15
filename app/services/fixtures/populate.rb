class Fixtures::Populate < ApplicationInteraction
  def execute
    response.each do |fixture_json|
      fixture = Fixture.find_or_create_by(id: fixture_json['id'])

      fixture.update!(
        kickoff_time: fixture_json['kickoff_time'],
        deadline_time: fixture_json['deadline_time'],
        team_h_difficulty: fixture_json['team_h_difficulty'],
        team_a_difficulty: fixture_json['team_a_difficulty'],
        team_h_score: fixture_json['team_h_score'],
        team_a_score: fixture_json['team_a_score'],
        round_id: fixture_json['event'],
        minutes: fixture_json['minutes'],
        team_a_id: fixture_json['team_a'],
        team_h_id: fixture_json['team_h'],
        started: fixture_json['started'],
        finished: fixture_json['finished'],
        provisional_start_time: fixture_json['provisional_start_time'],
        finished_provisional: fixture_json['finished_provisional'],
        round_day: fixture_json['event_day'],
        code: fixture_json['code'],
      )

      next unless fixture.started

      stats = {}

      key_stats_arr.each do |key_stat|
        stats[key_stat] = {}
        stats[key_stat]['initials'] = key_stat.split('_').map(&:first).join.upcase
        stats[key_stat]['name'] = key_stat.humanize.titleize
        ['home_team', 'away_team'].each do |team_stat|
          stats[key_stat][team_stat] = []

          fixture_json['stats'].find { |stat| stat[key_stat] }&.dig(key_stat, team_stat[0])&.each do |stat|
            player = Player.find(stat['element'])
            stats[key_stat][team_stat] << {
              value: stat['value'],
              player: { id: player.id, last_name: player.last_name }
            }
          end
        end
      end

      bps_arr = fixture_json['stats'].find { |stat| stat['bps'] }&.dig('bps')&.map { |_k, v| v }&.flatten
      stats['bps'] = bps_arr&.sort { |a, b| b['value'] <=> a['value'] }

      fixture.update!(stats: stats)
    end
  end

  private

  def key_stats_arr
    %w(goals_scored assists own_goals penalties_saved penalties_missed yellow_cards red_cards saves bonus)
  end

  def response
    HTTParty.get('https://fantasy.premierleague.com/drf/fixtures/')
  end
end
