class RoundChannel < ApplicationCable::Channel
  def subscribed
    stream_from "round_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
