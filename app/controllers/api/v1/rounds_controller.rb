class Api::V1::RoundsController < ApplicationController
  # GET /rounds
  def index
    respond_with(RoundSerializer.new(Round.all).serializable_hash[:data])
      # fixtures: round_serializer[:included].group_by do |group|
      #   Time.zone.at(group[:attributes][:kickoff_time].to_time).strftime('%A %-d %B %Y')
      # end
  end
end
