class Api::V1::ProfileController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  # GET /profile
  def index
    render json: { current_user: current_api_v1_user }
  end
end
