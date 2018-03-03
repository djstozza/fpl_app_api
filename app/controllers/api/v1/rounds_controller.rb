class Api::V1::RoundsController < ApplicationController
  # GET /api/v1/rounds
  def index
    respond_with(RoundDecorator.new(nil).rounds_hash)
  end
end
