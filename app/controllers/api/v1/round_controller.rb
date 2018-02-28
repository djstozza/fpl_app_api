class Api::V1::RoundController < ApplicationController
  # GET /api/v1/round/
  def index
    round = params[:round_id] ? Round.find(params[:round_id]) : Round.current

    options = {}
    options[:include] = [:fixtures]

    fixtures = RoundSerializer.new(round, options).serializable_hash[:included]

    respond_with(
      round: round,
      fixtures: fixtures
    )
  end
end
