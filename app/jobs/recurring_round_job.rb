class RecurringRoundJob < ApplicationInteraction
  def execute
    Rounds::Populate.run!
  end
end
