class FplTeamChannel < ApplicationCable::Channel
  def subscribed
    stream_from "fpl_team_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
