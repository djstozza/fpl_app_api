require 'rails_helper'

RSpec.describe WaiverPicks::UpdateOrder do
  it 'updates the waiver_pick order' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.create(:round, is_current: true, deadline_time: 3.days.from_now)
    league = FactoryBot.create(:league)
    fpl_team = FactoryBot.create(:fpl_team, league: league)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.create(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.create(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
    )

    waiver_pick_3 = FactoryBot.create(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 3,
    )

    waiver_pick_4 = FactoryBot.create(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 4,
    )

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_4.pick_number,
      user: fpl_team_list.user,
    )

    expect(outcome).to be_valid
    expect(waiver_pick_1.reload.pick_number).to eq(4)
    expect(waiver_pick_2.reload.pick_number).to eq(1)
    expect(waiver_pick_3.reload.pick_number).to eq(2)
    expect(waiver_pick_4.reload.pick_number).to eq(3)
  end

  it '#round_is_current' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    round = FactoryBot.build_stubbed(:round, is_current: false, deadline_time: 3.days.from_now)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: round,
      pick_number: 2,
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_1, waiver_pick_2]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_2.pick_number,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only make changes to your squad's line up for the upcoming round.")
  end

  it '#valid_time_period' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.days.from_now)
    expect(Round).to receive(:current).and_return(current_round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_1, waiver_pick_2]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_2.pick_number,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("The waiver pick deadline for this round has passed.")
  end

  it '#authorised_user' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(current_round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_1, waiver_pick_2]).at_least(1)

    user = FactoryBot.build_stubbed(:user)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_2.pick_number,
      user: user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#valid_pick_number' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(current_round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_1, waiver_pick_2]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_2.pick_number + 1,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("Pick number is invalid.")
  end

  it '#change_in_pick_number' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(current_round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_1, waiver_pick_2]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_1.pick_number,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("No change in pick number.")
  end

  it '#fpl_team_list_waiver_pick' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(current_round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
    )

    waiver_pick_3 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_2, waiver_pick_3]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_1.pick_number + 1,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("This waiver pick does not belong to your team.")
  end

  it '#pending_waiver_pick' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(current_round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: current_round)

    waiver_pick_1 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 1,
      status: 'approved',
    )

    waiver_pick_2 = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      fpl_team_list: fpl_team_list,
      round: current_round,
      pick_number: 2,
      status: 'approved',
    )

    expect(fpl_team_list).to receive(:waiver_picks).and_return([waiver_pick_1, waiver_pick_2]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      waiver_pick: waiver_pick_1,
      pick_number: waiver_pick_2.pick_number,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You can only edit pending waiver picks.")
  end
end
