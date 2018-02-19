class Rounds::BroadcastCurrentRound < ApplicationInteraction
  object :round, class: Round, default: -> { Round.current }

  def execute
    return if round.finished
    return if Time.parse(round.deadline_time) > Time.now

    options = {}
    options[:include] = [:fixtures]

    fixtures = RoundSerializer.new(round, options).serializable_hash[:included]

    ActionCable.server.broadcast("round_#{round.id}", { round: round, fixtures: fixtures })
  end
end
