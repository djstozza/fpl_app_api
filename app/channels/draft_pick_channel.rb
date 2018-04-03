class DraftPickChannel < ApplicationCable::Channel
  def subscribed
    stream_from "league_#{params[:room]}_draft_picks"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
