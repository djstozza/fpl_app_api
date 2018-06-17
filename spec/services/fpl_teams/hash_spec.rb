require 'rails_helper'

RSpec.describe FplTeams::Hash do
  it 'foo' do
    user = FactoryBot.create(:user)
    fpl_team = FactoryBot.create(:fpl_team, user: user)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)
    league = fpl_team.league

    params = {
      user: user,
      fpl_team: fpl_team,
      fpl_team_list: fpl_team_list,
    }

    outcome = described_class.run(params)

    result = outcome.result
    expect(result[:fpl_team]).to eq(fpl_team)
    expect(result[:current_user]).to eq(user)
    expect(result[:fpl_team_list]).to eq(fpl_team_list)
    expect(result[:league]).to eq(fpl_team.league)
    expect(result[:user_owns_fpl_team]).to be_truthy
    expect(result[:league_status]).to eq(league.status)
    expect(result[:fpl_team_lists]).to eq(fpl_team.fpl_team_lists)
  end
end
