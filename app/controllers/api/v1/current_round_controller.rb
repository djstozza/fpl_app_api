class Api::V1::CurrentRoundController < ApplicationController
  # GET /api/v1/round/
  def index
    round = Round.current

    render json: {
      current_round: round,
      current_round_status: round.status,
      current_round_deadline_time: round.current_deadline_time + 1.second,
    }
  end
end
