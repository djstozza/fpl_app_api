class Players::PopulateHistory < ApplicationInteraction
  object :player, class: Player
  object :response, class: HTTParty::Response,
    default: -> { HTTParty.get("https://fantasy.premierleague.com/drf/element-summary/#{player.id}") }

  def execute
    player.update(
      player_fixture_histories: response['history'],
      player_past_histories: response['history_past']
    )

    return if response['history']

    player_stats_arr.each do |stat|
      player.update(
        stat =>  history_json['history'].inject(0) { |sum, fixtue_history| sum + fixtue_history[stat] }
      )
    end
  end

  private

  def player_stats_arr
    %w(
      open_play_crosses
      big_chances_created
      clearances_blocks_interceptions
      recoveries
      key_passes
      tackles
      winning_goals
      dribbles
      fouls
      errors_leading_to_goal
      big_chances_missed
      offside
      attempted_passes
      target_missed
    )
  end
end
