class Players::PopulateHistory < ApplicationInteraction
  object :player, class: Player

  def execute
    player.update(
      player_fixture_histories: response['history'],
      player_past_histories: response['history_past']
    )
  end

  private

  def response
    HTTParty.get("https://fantasy.premierleague.com/drf/element-summary/#{player.id}")
  end
end
