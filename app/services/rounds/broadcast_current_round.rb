class Rounds::BroadcastCurrentRound < ApplicationInteraction
  object :round, class: Round, default: -> { Round.current }

  def execute
    return if round.finished
    return if round.deadline_time.to_time > Time.now

    fixtures = fixtures = round.decorate.fixture_hash

    ActionCable.server.broadcast("round_#{round.id}", { round: round, fixtures: fixtures })
  end
end
