require 'rails_helper'

RSpec.describe TeamDecorator do
  it '#fixture_hash' do
    team = FactoryBot.create(:team)
    fixture_1 = FactoryBot.create(:fixture, :team_h_win, home_team: team)
    fixture_2 = FactoryBot.create(:fixture, :team_a_win, away_team: team)

    fixture_hash = team.decorate.fixture_hash

    expect(fixture_hash).to contain_exactly(
      {
        "kickoff_time" => fixture_1.kickoff_time,
        "fixture_id" => fixture_1.id,
        "opponent_id" => fixture_1.team_a_id,
        "opponent_short_name" => fixture_1.away_team.short_name,
        "opponent_name" => fixture_1.away_team.name,
        "team_h_id" => fixture_1.team_h_id,
        "team_h_score" => fixture_1.team_h_score,
        "team_a_score" => fixture_1.team_a_score,
        "team_h_difficulty" => fixture_1.team_h_difficulty,
        "team_a_difficulty" => fixture_1.team_a_difficulty,
        "round_id" => fixture_1.round_id,
        "score" => "#{fixture_1.team_h_score} - #{fixture_1.team_a_score}",
        "leg" => 'H',
        "advantage" => fixture_1.team_a_difficulty - fixture_1.team_h_difficulty,
      },
      {
        "kickoff_time" => fixture_2.kickoff_time,
        "fixture_id" => fixture_2.id,
        "opponent_id" => fixture_2.team_h_id,
        "opponent_short_name" => fixture_2.home_team.short_name,
        "opponent_name" => fixture_2.home_team.name,
        "team_h_id" => fixture_2.team_h_id,
        "team_h_score" => fixture_2.team_h_score,
        "team_a_score" => fixture_2.team_a_score,
        "team_h_difficulty" => fixture_2.team_h_difficulty,
        "team_a_difficulty" => fixture_2.team_a_difficulty,
        "round_id" => fixture_2.round_id,
        "score" => "#{fixture_2.team_h_score} - #{fixture_2.team_a_score}",
        "leg" => 'A',
        "advantage" => fixture_2.team_h_difficulty - fixture_2.team_a_difficulty,
      }
    )
  end
end
