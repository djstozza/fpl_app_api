require 'rails_helper'

RSpec.describe Leagues::ProcessNextLineUp do
  it 'is valid' do
    league = FactoryBot.build_stubbed(:league)
    round = FactoryBot.build_stubbed(:round, is_current: true, data_checked: true)
    next_round = FactoryBot.build_stubbed(:round, is_next: true)

    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(league).to receive(:fpl_teams).and_return([fpl_team])

    expect_to_run(FplTeams::ProcessNextLineUp, with: { fpl_team: fpl_team, round: round, next_round: next_round })

    outcome = described_class.run(league: league, round: round, next_round: next_round)
    expect(outcome).to be_valid
  end

  it 'does not trigger FplTeams::ProcessNextLineUp if the round is not data_checked' do
    league = FactoryBot.build_stubbed(:league)
    round = FactoryBot.build_stubbed(:round, is_current: true, data_checked: false)
    next_round = FactoryBot.build_stubbed(:round, is_next: true)

    expect(league).not_to receive(:fpl_teams)
    expect_not_to_run(FplTeams::ProcessNextLineUp)

    outcome = described_class.run(league: league, round: round, next_round: next_round)
    expect(outcome).to be_valid
  end

  it 'does not trigger FplTeams::ProcessNextLineUp if there is no next_round' do
    league = FactoryBot.build_stubbed(:league)
    round = FactoryBot.build_stubbed(:round, is_current: true, data_checked: false)

    expect(league).not_to receive(:fpl_teams)
    expect_not_to_run(FplTeams::ProcessNextLineUp)

    outcome = described_class.run(league: league, round: round, next_round: nil)
    expect(outcome).to be_valid
  end
end
