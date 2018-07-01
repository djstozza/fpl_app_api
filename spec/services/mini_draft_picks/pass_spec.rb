require 'rails_helper'

RSpec.describe MiniDraftPicks::Pass do
  it 'creates a passed mini draft pick' do
    round = FactoryBot.create(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)

    league = FactoryBot.create(:league)
    user = FactoryBot.create(:user)

    fpl_team_1 = FactoryBot.create(:fpl_team, league: league, user: user, mini_draft_pick_number: 1)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round)

    fpl_team_2 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 2)

    expect_to_delay_run(
      MiniDraftPicks::Broadcast,
      with: {
        league: league,
        fpl_team_list: fpl_team_list,
        user: user,
        passed: true,
      }
    )

    outcome = described_class.run(league: league, user: user, fpl_team_list: fpl_team_list)
    result = outcome.result

    # Creates the mini draft pick
    expect(result.pick_number).to eq(MiniDraftPick.count)
    expect(result.season).to eq('summer')
    expect(result.in_player).to be_nil
    expect(result.out_player).to be_nil
    expect(result.passed).to be_truthy
    expect(result.fpl_team).to eq(fpl_team_1)

    # Valid mini draft pick hash
    mini_draft_pick_hash = outcome.mini_draft_pick_hash
    expect(mini_draft_pick_hash[:next_fpl_team]).to eq(fpl_team_2)
    expect(mini_draft_pick_hash[:current_mini_draft_pick_user]).to eq(fpl_team_2.user)
    expect(mini_draft_pick_hash[:mini_draft_picks]).to be_empty

    current_mini_draft_pick = mini_draft_pick_hash[:current_mini_draft_pick]
    expect(current_mini_draft_pick.pick_number).to eq(MiniDraftPick.count + 1)
    expect(current_mini_draft_pick.fpl_team).to eq(fpl_team_2)
  end

  it 'fails if the deadline_time has passed' do
    round = FactoryBot.build_stubbed(
      :round,
      mini_draft: true,
      is_current: true,
      deadline_time: 1.day.from_now
    )
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })

    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
    )

    expect(outcome.errors.full_messages).to contain_exactly("The deadline time for making mini draft picks has passed.")
  end

  it 'fails if the round is not current' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: false)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
    )

    expect(outcome.errors.full_messages).to contain_exactly(
      "You can only make changes to your squad's line up for the upcoming round.",
    )
  end

  it 'fails if the fpl_team_list round is not a mini_draft round' do
    round = FactoryBot.build_stubbed(:round, mini_draft: false, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
    )

    expect(outcome.errors.full_messages).to contain_exactly("Mini draft picks cannot be performed at this time.")
  end
end
