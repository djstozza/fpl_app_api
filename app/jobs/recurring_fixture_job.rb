class RecurringFixtureJob < ApplicationInteraction
  def execute
    Fixtures::Populate.run!
    Rounds::BroadcastCurrentRound.run!
  end
end
