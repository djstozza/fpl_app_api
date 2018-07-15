require 'rails_helper'

RSpec.describe RecurringFixtureJob do
  it 'is valid' do
    expect_to_execute(Fixtures::Populate)
    expect_to_execute(Rounds::BroadcastCurrentRound)
    described_class.run!
  end
end
