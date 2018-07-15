class Rounds::BroadcastCurrentRound < ApplicationInteraction
  def execute
    return if round.finished
    return if round.deadline_time > Time.now

    fixtures = round.decorate.fixture_hash

    ActionCable.server.broadcast("round_#{round.id}", { round: round, fixtures: fixtures })
  end

  private

  def round
    Round.current
  end
end
