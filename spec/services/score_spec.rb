require 'rails_helper'

RSpec.describe Score do
  it 'is valid' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.ago)
    next_round = FactoryBot.create(:round, is_next: true)

    league = FactoryBot.create(:league, status: 'active')

    fpl_team = FactoryBot.create(:fpl_team, league: league)

    expect_to_run(::Leagues::Score, with: { league: league, round: round })
    expect_to_run(::Leagues::Rank, with: { league: league, round: round })
    expect_to_run(::Leagues::ProcessNextLineUp, with: { league: league, round: round, next_round: next_round })
    expect_to_run(
      ::FplTeams::Broadcast,
      with: {
        fpl_team: fpl_team,
        user: fpl_team.user,
        show_list_positions: true,
        show_waiver_picks: true,
      },
    )
    outcome = described_class.run
    expect(outcome).to be_valid
  end

  it 'returns if the final round is finished' do
    FactoryBot.create(:round, finished: true, deadline_time: 1.day.ago)
    FactoryBot.create(:league, status: 'active')

    expect_not_to_run(::Leagues::Score)
    expect_not_to_run(::Leagues::Rank)
    expect_not_to_run(::Leagues::ProcessNextLineUp)

    outcome = described_class.run
    expect(outcome).to be_valid
  end

  it "returns if the round hasn't started" do
    FactoryBot.create(:round, deadline_time: 59.minutes.ago, deadline_time_game_offset: 3600)

    FactoryBot.create(:league, status: 'active')

    expect_not_to_run(::Leagues::Score)
    expect_not_to_run(::Leagues::Rank)
    expect_not_to_run(::Leagues::ProcessNextLineUp)

    outcome = described_class.run
    expect(outcome).to be_valid
  end
end
