require 'rails_helper'

RSpec.describe Leagues::Score do
  it 'is valid' do
    league = FactoryBot.create(:league)
    round = FactoryBot.create(:round)

    fpl_team = FactoryBot.create(:fpl_team, league: league)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

    expect_to_execute(FplTeamLists::Score, with: { fpl_team_list: fpl_team_list })
    expect_to_execute(FplTeams::Score, with: { fpl_team: fpl_team })

    outcome = described_class.run(league: league, round: round)
    expect(outcome).to be_valid
  end
end
