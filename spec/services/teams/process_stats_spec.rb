require 'rails_helper'

RSpec.describe Teams::ProcessStats do
  it "updates team stats" do
    team = FactoryBot.create(:team)

    FactoryBot.create(:fixture, home_team: team, team_h_score: 2, team_a_score: 0, finished: true)
    FactoryBot.create(:fixture, away_team: team, team_a_score: 0, team_h_score: 1, finished: true)
    FactoryBot.create(:fixture, home_team: team, team_h_score: 0, team_a_score: 0, finished: true)
    FactoryBot.create(:fixture, away_team: team, team_a_score: 3, team_h_score: 2, finished: true)
    FactoryBot.create(:fixture, home_team: team, team_h_score: 1, team_a_score: 1, finished: true)
    FactoryBot.create(:fixture, home_team: team, team_h_score: 2, team_a_score: 4, finished: true)
    FactoryBot.create(:fixture, home_team: team, team_h_score: 0, team_a_score: 1, finished: false)

    result = described_class.run!(team: team)

    expect(result.played).to eq(6)
    expect(result.clean_sheets).to eq(2)
    expect(result.goals_for).to eq(8)
    expect(result.goals_against).to eq(8)
    expect(result.goal_difference).to be_zero
    expect(result.form).to eq(["W", "L", "D", "W", "D", "L"])
    expect(result.current_form).to eq("LDWDL")
  end
end
