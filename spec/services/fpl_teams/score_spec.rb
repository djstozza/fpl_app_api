require 'rails_helper'

RSpec.describe FplTeams::Score do
  it 'updates the fpl_team score' do
    fpl_team = FactoryBot.build_stubbed(:fpl_team)
    fpl_team_list_1 = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, total_score: 50)
    fpl_team_list_2 = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, total_score: 40)

    expect(fpl_team).to receive(:fpl_team_lists).and_return([fpl_team_list_1, fpl_team_list_2])
    expect(fpl_team).to receive(:save)

    described_class.run(fpl_team: fpl_team)

    expect(fpl_team.total_score).to eq(fpl_team_list_1.total_score + fpl_team_list_2.total_score)
  end
end
