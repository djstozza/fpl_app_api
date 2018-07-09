class Api::V1::RoundController < ApplicationController
  # GET /api/v1/round/
  def index
    round = params[:round_id] ? Round.find(params[:round_id]) : Round.current

    fixtures = round.decorate.fixture_hash

    render json: { round: round, fixtures: fixtures }
  end
end
