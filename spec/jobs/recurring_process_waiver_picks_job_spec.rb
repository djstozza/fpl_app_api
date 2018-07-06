require 'rails_helper'

RSpec.describe RecurringProcessWaiverPicksJob do
  it 'triggers the process waiver picks service if there are waiver picks and the cuttoff date has been reached' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 25.hours.from_now)

    expect(Round).to receive(:current).and_return(round).at_least(1)
    expect(WaiverPick).to receive(:where).and_return([double(WaiverPick)]).at_least(1)

    expect_to_delay_run(::WaiverPicks::Process)

    described_class.run!
    Timecop.return
  end

  it 'does not trigger the process waiver service if there are no waiver picks' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 25.hours.from_now)

    expect(Round).to receive(:current).and_return(round).at_least(1)
    expect(WaiverPick).to receive(:where).and_return([]).at_least(1)

    expect_to_not_run_delayed(::WaiverPicks::Process)

    described_class.run!
    Timecop.return
  end

  it 'does not trigger the process waiver service if the date is prior to the cuttoff date' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 2.days.from_now)

    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect_to_not_run_delayed(::WaiverPicks::Process)

    described_class.run!
    Timecop.return
  end

  it 'does not trigger the process waiver service if the cutoff date has passed' do
    current_time = Time.new(2018, 07, 07)
    Timecop.freeze current_time
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.hour.ago)

    expect(Round).to receive(:current).and_return(round).at_least(1)

    expect_to_not_run_delayed(::WaiverPicks::Process)

    described_class.run!
    Timecop.return
  end
end
