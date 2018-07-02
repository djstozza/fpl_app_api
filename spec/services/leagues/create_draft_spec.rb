require 'rails_helper'

RSpec.describe Leagues::CreateDraft do
  it 'creates draft picks for all fpl teams' do
    league = FactoryBot.create(:league, status: 'create_draft')
    fpl_team_1 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_3 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_4 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_5 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_6 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_7 = FactoryBot.create(:fpl_team, league: league)
    fpl_team_8 = FactoryBot.create(:fpl_team, league: league)

    described_class.run!(league: league, user: league.commissioner)

    expect(DraftPick.count).to eq(Leagues::CreateDraft::PICKS_PER_TEAM * FplTeam.count)

    expect(fpl_team_1.draft_picks.pluck(:pick_number))
      .to contain_exactly(1, 16, 17, 32, 33, 48, 49, 64, 65, 80, 81, 96, 97, 112, 113, 128)
    expect(fpl_team_2.draft_picks.pluck(:pick_number))
      .to contain_exactly(2, 15, 18, 31, 34, 47, 50, 63, 66, 79, 82, 95, 98, 111, 114, 127)
    expect(fpl_team_3.draft_picks.pluck(:pick_number))
      .to contain_exactly(3, 14, 19, 30, 35, 46, 51, 62, 67, 78, 83, 94, 99, 110, 115, 126)
    expect(fpl_team_4.draft_picks.pluck(:pick_number))
      .to contain_exactly(4, 13, 20, 29, 36, 45, 52, 61, 68, 77, 84, 93, 100, 109, 116, 125)
    expect(fpl_team_5.draft_picks.pluck(:pick_number))
      .to contain_exactly(5, 12, 21, 28, 37, 44, 53, 60, 69, 76, 85, 92, 101, 108, 117, 124)
    expect(fpl_team_6.draft_picks.pluck(:pick_number))
      .to contain_exactly(6, 11, 22, 27, 38, 43, 54, 59, 70, 75, 86, 91, 102, 107, 118, 123)
    expect(fpl_team_7.draft_picks.pluck(:pick_number))
      .to contain_exactly(7, 10, 23, 26, 39, 42, 55, 58, 71, 74, 87, 90, 103, 106, 119, 122)
    expect(fpl_team_8.draft_picks.pluck(:pick_number))
      .to contain_exactly(8, 9, 24, 25, 40, 41, 56, 57, 72, 73, 88, 89, 104, 105, 120, 121)
  end

  it '#user_is_commissioner' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')
    user = FactoryBot.build_stubbed(:user)

    expect_any_instance_of(described_class)
      .to receive(:fpl_team_count).and_return(League::MIN_FPL_TEAM_QUOTA)

    outcome = described_class.run(league: league, user: user)
    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to edit this league.")
  end

  it '#league_status' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')

    expect_any_instance_of(described_class)
      .to receive(:fpl_team_count).and_return(League::MIN_FPL_TEAM_QUOTA)

    outcome = described_class.run(league: league, user: league.commissioner)
    expect(outcome.errors.full_messages).to contain_exactly("You cannot initiate the draft at this time.")
  end

  it '#min_fpl_team_quota' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')

    expect_any_instance_of(described_class)
      .to receive(:fpl_team_count).and_return(League::MIN_FPL_TEAM_QUOTA - 1)

    outcome = described_class.run(league: league, user: league.commissioner)
    expect(outcome.errors.full_messages)
      .to contain_exactly("There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present for the draft to occcur.")
  end
end
