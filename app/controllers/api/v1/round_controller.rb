class Api::V1::RoundController < ApplicationController
  # GET /round/
  def index
    round = params[:round_id] ? Round.find(params[:round_id]) : Round.current

    Time.zone = params[:tz]
    options = {}
    options[:include] = [:fixtures]

    fixtures = RoundSerializer.new(round, options).serializable_hash[:included].group_by do |group|
      Time.zone.at(group[:attributes][:kickoff_time].to_time).strftime('%A %-d %B %Y')
    end

    respond_with(
      round: round,
      fixtures: fixtures
    )
  end
end
