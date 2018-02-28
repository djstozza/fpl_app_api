class Api::V1::RoundsController < ApplicationController
  # GET /api/v1/rounds
  def index
    respond_with(RoundSerializer.new(Round.all.sort).serializable_hash[:data])
  end
end
