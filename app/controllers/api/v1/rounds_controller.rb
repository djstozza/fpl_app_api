class Api::V1::RoundsController < ApplicationController
  # GET /rounds
  def index
    respond_with(RoundSerializer.new(Round.all.sort).serializable_hash[:data])
  end
end
