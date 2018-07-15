RSpec.describe RecurringTeamJob do
  it "is valid" do
    expect_to_execute(Teams::Populate)
    described_class.run!
  end
end
