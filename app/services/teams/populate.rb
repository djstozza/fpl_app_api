class Teams::Populate < ApplicationInteraction
  object :responses, class: HTTParty::Response,
    default: -> { HTTParty.get('https://fantasy.premierleague.com/drf/teams') }

  def execute
    responses.each do |team_response|
      team = Team.find_or_create_by(code: team_response['code'])
      team.update(
        name: team_response['name'],
        short_name: team_response['short_name'],
        strength: team_response['strength'],
        played: team_response['played'],
        link_url: team_response['link_url'],
        strength_overall_home: team_response['strength_overall_home'],
        strength_overall_away: team_response['strength_overall_away'],
        strength_attack_home: team_response['strength_attack_home'],
        strength_attack_away: team_response['strength_attack_away'],
        strength_defence_home: team_response['strength_defence_home'],
        strength_defence_away: team_response['strength_defence_away'],
        team_division: team_response['team_division'],
      )

      compose(
        Teams::ProcessStats,
        team: team
      )
    end
  end
end
