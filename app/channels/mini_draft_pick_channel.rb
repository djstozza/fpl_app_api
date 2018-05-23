class MiniDraftPickChannel < ApplicationCable::Channel
  def subscribed
    stream_from "league_#{params[:room]}_mini_draft_picks"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
