class MiniDraftPicksController < ApplicationController
  before_action :set_mini_draft_pick, only: [:show, :update, :destroy]

  respond_to :json

  def index
    @mini_draft_picks = MiniDraftPick.all
    respond_with(@mini_draft_picks)
  end

  def show
    respond_with(@mini_draft_pick)
  end

  def create
    @mini_draft_pick = MiniDraftPick.new(mini_draft_pick_params)
    @mini_draft_pick.save
    respond_with(@mini_draft_pick)
  end

  def update
    @mini_draft_pick.update(mini_draft_pick_params)
    respond_with(@mini_draft_pick)
  end

  def destroy
    @mini_draft_pick.destroy
    respond_with(@mini_draft_pick)
  end

  private
    def set_mini_draft_pick
      @mini_draft_pick = MiniDraftPick.find(params[:id])
    end

    def mini_draft_pick_params
      params[:mini_draft_pick]
    end
end
