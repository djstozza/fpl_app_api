require 'rails_helper'

RSpec.describe Leagues::GenerateFplTeamDraftPickNumbers do
  it 'generates pick numbers for each fpl team' do
    league = FactoryBot.build_stubbed(:league, status: 'generate_draft_picks')

    fpl_team_1 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_3 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_4 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_5 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_6 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_7 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_8 = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(league).to receive(:fpl_teams).and_return([
      fpl_team_1,
      fpl_team_2,
      fpl_team_3,
      fpl_team_4,
      fpl_team_5,
      fpl_team_6,
      fpl_team_7,
      fpl_team_8,
    ])

    allow_any_instance_of(described_class).to receive(:shuffled_fpl_teams).and_return([
      fpl_team_5,
      fpl_team_2,
      fpl_team_8,
      fpl_team_1,
      fpl_team_6,
      fpl_team_3,
      fpl_team_7,
      fpl_team_4,
    ])

    expect(fpl_team_1).to receive(:save)
    expect(fpl_team_2).to receive(:save)
    expect(fpl_team_3).to receive(:save)
    expect(fpl_team_4).to receive(:save)
    expect(fpl_team_5).to receive(:save)
    expect(fpl_team_6).to receive(:save)
    expect(fpl_team_7).to receive(:save)
    expect(fpl_team_8).to receive(:save)
    expect(league).to receive(:save)

    result = described_class.run!(league: league, user: league.commissioner)
    expect(result.create_draft?).to be_truthy

    expect(fpl_team_1.draft_pick_number).to eq(4)
    expect(fpl_team_2.draft_pick_number).to eq(2)
    expect(fpl_team_3.draft_pick_number).to eq(6)
    expect(fpl_team_4.draft_pick_number).to eq(8)
    expect(fpl_team_5.draft_pick_number).to eq(1)
    expect(fpl_team_6.draft_pick_number).to eq(5)
    expect(fpl_team_7.draft_pick_number).to eq(7)
    expect(fpl_team_8.draft_pick_number).to eq(3)
  end

  it '#user_is_commissioner' do
    league = FactoryBot.build_stubbed(:league, status: 'generate_draft_picks')
    user = FactoryBot.build_stubbed(:user)

    fpl_teams = []
    League::MIN_FPL_TEAM_QUOTA.times { fpl_teams << double(FplTeam) }

    expect(league).to receive(:fpl_teams).and_return(fpl_teams)

    outcome = described_class.run(league: league, user: user)
    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to edit this league.")
  end

  it '#min_fpl_team_quota' do
    league = FactoryBot.build_stubbed(:league, status: 'generate_draft_picks')

    fpl_teams = []
    (League::MIN_FPL_TEAM_QUOTA - 1).times { fpl_teams << double(FplTeam) }

    expect(league).to receive(:fpl_teams).and_return(fpl_teams)

    outcome = described_class.run(league: league, user: league.commissioner)
    expect(outcome.errors.full_messages)
      .to contain_exactly("There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present for the draft to occcur.")
  end

  it '#league_status' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')

    fpl_teams = []
    League::MIN_FPL_TEAM_QUOTA.times { fpl_teams << double(FplTeam) }

    expect(league).to receive(:fpl_teams).and_return(fpl_teams)

    outcome = described_class.run(league: league, user: league.commissioner)
    expect(outcome.errors.full_messages).to contain_exactly("You cannot generate draft pick numbers at this time.")
  end
end
