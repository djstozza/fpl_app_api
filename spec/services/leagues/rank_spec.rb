require 'rails_helper'

RSpec.describe Leagues::Rank do
  it 'ranks the fpl teams and fpl team lists based on their total scores' do
    league = FactoryBot.create(:league)
    round = FactoryBot.create(:round)

    fpl_team_1 = FactoryBot.create(:fpl_team, total_score: 50, league: league)
    fpl_team_list_1 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round, total_score: 50)

    fpl_team_2 = FactoryBot.create(:fpl_team, total_score: 50, league: league)
    fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round, total_score: 40)

    fpl_team_3 = FactoryBot.create(:fpl_team, total_score: 40, league: league)
    fpl_team_list_3 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_3, round: round, total_score: 50)

    outcome = described_class.run(league: league, round: round)
    expect(outcome).to be_valid

    expect(fpl_team_1.reload.rank).to eq(1)
    expect(fpl_team_2.reload.rank).to eq(1)
    expect(fpl_team_3.reload.rank).to eq(3)

    expect(fpl_team_list_1.reload.rank).to eq(1)
    expect(fpl_team_list_3.reload.rank).to eq(1)
    expect(fpl_team_list_2.reload.rank).to eq(3)
  end
end
