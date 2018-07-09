class Api::V1::RoundsController < ApplicationController
  # GET /api/v1/rounds
  def index
    render json: RoundDecorator.new(nil).rounds_hash
  end
end
