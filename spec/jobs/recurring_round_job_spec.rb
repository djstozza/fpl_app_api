RSpec.describe RecurringRoundJob do
  it "is valid" do
    expect_to_execute(Rounds::Populate)
    described_class.run!
  end
end
