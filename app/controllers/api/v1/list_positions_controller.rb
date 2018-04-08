class ListPositionsController < ApplicationController
  before_action :set_list_position, only: [:show, :update, :destroy]

  respond_to :json

  def index
    @list_positions = ListPosition.all
    respond_with(@list_positions)
  end

  def show
    respond_with(@list_position)
  end

  def create
    @list_position = ListPosition.new(list_position_params)
    @list_position.save
    respond_with(@list_position)
  end

  def update
    @list_position.update(list_position_params)
    respond_with(@list_position)
  end

  def destroy
    @list_position.destroy
    respond_with(@list_position)
  end

  private
    def set_list_position
      @list_position = ListPosition.find(params[:id])
    end

    def list_position_params
      params[:list_position]
    end
end
