require 'rails_helper'

RSpec.describe Leagues::Activate do
  it 'activates the league and assigns mini_draft_pick_numbers' do
    league = FactoryBot.create(:league, status: 'draft')
    fpl_team_1 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.create(:fpl_team, league: league)

    FactoryBot.create(:draft_pick, :mini_draft, league: league, fpl_team: fpl_team_1)
    FactoryBot.create(:draft_pick, :mini_draft, league: league, fpl_team: fpl_team_2)

    expect_to_execute(::FplTeams::ProcessInitialLineUp, with: { fpl_team: fpl_team_1 })
    expect_to_execute(::FplTeams::ProcessInitialLineUp, with: { fpl_team: fpl_team_2 })

    result = described_class.run!(league: league)

    expect(result.active?).to be_truthy
    expect(fpl_team_1.reload.mini_draft_pick_number).to eq(1)
    expect(fpl_team_2.reload.mini_draft_pick_number).to eq(2)
  end
end
