class Api::V1::PositionsController < ApplicationController
  # GET /api/v1/positions
  def index
    render json: PositionSerializer.new(Position.all).serializable_hash[:data]
  end
end
