require 'rails_helper'

RSpec.describe RecurringPlayerJob do
  it "is valid" do
    expect_to_execute(Players::Populate)
    described_class.run!
  end
end
