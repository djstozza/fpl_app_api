require 'rails_helper'

RSpec.describe Leagues::UpdateDraftPickNumberOrder do
  it 'updates fpl team draft pick numbers - increase draft pick number' do
    league = FactoryBot.create(:league, status: 'create_draft')

    fpl_team_1 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 1)
    fpl_team_2 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 2)
    fpl_team_3 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 3)
    fpl_team_4 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 4)

    described_class.run!(
      league: league,
      user: league.commissioner,
      fpl_team: fpl_team_1,
      draft_pick_number: fpl_team_4.draft_pick_number,
    )

    expect(fpl_team_1.reload.draft_pick_number).to eq(4)
    expect(fpl_team_2.reload.draft_pick_number).to eq(1)
    expect(fpl_team_3.reload.draft_pick_number).to eq(2)
    expect(fpl_team_4.reload.draft_pick_number).to eq(3)
  end

  it 'updates fpl team draft pick numbers - decrease draft pick number' do
    league = FactoryBot.create(:league, status: 'create_draft')

    fpl_team_1 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 1)
    fpl_team_2 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 2)
    fpl_team_3 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 3)
    fpl_team_4 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 4)

    described_class.run!(
      league: league,
      user: league.commissioner,
      fpl_team: fpl_team_4,
      draft_pick_number: fpl_team_1.draft_pick_number,
    )

    expect(fpl_team_1.reload.draft_pick_number).to eq(2)
    expect(fpl_team_2.reload.draft_pick_number).to eq(3)
    expect(fpl_team_3.reload.draft_pick_number).to eq(4)
    expect(fpl_team_4.reload.draft_pick_number).to eq(1)
  end

  it '#user_is_commissioner' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')
    fpl_team_1 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(league).to receive(:fpl_teams).and_return([fpl_team_1, fpl_team_2]).at_least(1)

    outcome = described_class.run(
      league: league,
      user: fpl_team_1.user,
      fpl_team: fpl_team_1,
      draft_pick_number: fpl_team_2.draft_pick_number,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to edit this league.")
  end

  it '#league_status' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team_1 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(league).to receive(:fpl_teams).and_return([fpl_team_1, fpl_team_2]).at_least(1)

    outcome = described_class.run(
      league: league,
      user: league.commissioner,
      fpl_team: fpl_team_1,
      draft_pick_number: fpl_team_2.draft_pick_number,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You cannot make any more changes to the draft pick order.")
  end

  it '#league_status' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')
    fpl_team_1 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(league).to receive(:fpl_teams).and_return([fpl_team_1, fpl_team_2]).at_least(1)

    outcome = described_class.run(
      league: league,
      user: league.commissioner,
      fpl_team: fpl_team_1,
      draft_pick_number: fpl_team_2.draft_pick_number + 1,
    )

    expect(outcome.errors.full_messages).to contain_exactly("Draft pick number is invalid.")
  end

  it '#fpl_team_in_league' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')
    fpl_team_1 = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_2 = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(league).to receive(:fpl_teams).and_return([fpl_team_2]).at_least(1)

    outcome = described_class.run(
      league: league,
      user: league.commissioner,
      fpl_team: fpl_team_1,
      draft_pick_number: fpl_team_2.draft_pick_number,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only update draft pick numbers for fpl teams that are part of your league.")
  end
end
