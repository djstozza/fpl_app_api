class RecurringPlayerJob < ApplicationInteraction
  def execute
    Players::Populate.run!
  end
end
