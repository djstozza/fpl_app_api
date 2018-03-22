class Api::V1::PositionsController < ApplicationController
  # GET /api/v1/positions
  def index
    render json: Position.pluck_to_hash(:id, :singular_name_short, :singular_name, :plural_name, :plural_name_short)
  end
end
