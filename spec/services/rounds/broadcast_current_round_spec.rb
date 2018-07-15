require 'rails_helper'

RSpec.describe  Rounds::BroadcastCurrentRound do
  it "broadcasts the current round" do
    round = FactoryBot.create(:round, is_current: true, deadline_time: Time.now)

    FactoryBot.create(:fixture, round: round)

    expect(ActionCable.server).to receive(:broadcast).with(
      "round_#{round.id}",
      { round: round, fixtures: round.decorate.fixture_hash },
    )

    described_class.run!
  end

  it "doesn't broadcast if the current round is finished" do
    round = FactoryBot.build_stubbed(:round, is_current: true, finished: true, deadline_time: 2.days.ago)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect(ActionCable.server).not_to receive(:broadcast)

    described_class.run!
  end

  it "doesn't broadcast if the current round deadline_time hasn't passed" do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.minute.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect(ActionCable.server).not_to receive(:broadcast)

    described_class.run!
  end
end
