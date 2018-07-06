require 'rails_helper'

RSpec.describe RecurringExpireTradeGroupsJob do
  it 'triggers the expire trade group service if the date is the same as the round deadline_time' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.hour.from_now)

    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect(InterTeamTradeGroup).to receive(:where).and_return([double(InterTeamTradeGroup)]).at_least(1)

    expect_to_delay_run(::InterTeamTradeGroups::Expire)

    described_class.run!
    Timecop.return
  end

  it 'does not trigger the service if there are no inter team trade groups' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.hour.from_now)

    expect(Round).to receive(:current).and_return(round).at_least(1)
    expect(InterTeamTradeGroup).to receive(:where).and_return([]).at_least(1)

    expect_to_not_run_delayed(::InterTeamTradeGroups::Expire)

    described_class.run!
    Timecop.return
  end

  it 'does not trigger the service if the date is prior to the date' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)

    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect_to_not_run_delayed(::InterTeamTradeGroups::Expire)

    described_class.run!
    Timecop.return
  end

  it 'does not trigger the service if the date has passed' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.hour.ago)

    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect_to_not_run_delayed(::InterTeamTradeGroups::Expire)

    described_class.run!
    Timecop.return
  end
end
