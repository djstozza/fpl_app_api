class RecurringTeamJob < ApplicationInteraction
  def execute
    Teams::Populate.run!
  end
end
