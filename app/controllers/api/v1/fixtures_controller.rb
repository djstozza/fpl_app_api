class Api::V1::FixturesController < ApplicationController
  before_action :set_fixture, only: [:show, :update, :destroy]

  # GET /fixtures
  def index
    @fixtures = Fixture.all

    render json: @fixtures
  end

  # GET /fixtures/1
  def show
    render json: @fixture
  end

  # POST /fixtures
  def create
    @fixture = Fixture.new(fixture_params)

    if @fixture.save
      render json: @fixture, status: :created, location: @fixture
    else
      render json: @fixture.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /fixtures/1
  def update
    if @fixture.update(fixture_params)
      render json: @fixture
    else
      render json: @fixture.errors, status: :unprocessable_entity
    end
  end

  # DELETE /fixtures/1
  def destroy
    @fixture.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fixture
      @fixture = Fixture.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def fixture_params
      params.fetch(:fixture, {})
    end
end
