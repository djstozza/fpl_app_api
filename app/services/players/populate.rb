class Players::Populate < ApplicationInteraction
  object :response, class: HTTParty::Response,
    default: -> { HTTParty.get('https://fantasy.premierleague.com/drf/elements/') }

  def execute
    response.each do |player_json|
      player = Player.find_or_create_by(code: player_json['code'])
      player.update(
        first_name: player_json['first_name'],
        last_name: player_json['second_name'],
        squad_number: player_json['squad_number'],
        team_code: player_json['team_code'],
        photo: player_json['photo'],
        web_name: player_json['web_name'],
        status: player_json['status'],
        news: player_json['news'],
        now_cost: player_json['now_cost'],
        chance_of_playing_this_round: player_json['chance_of_playing_this_round'],
        chance_of_playing_next_round: player_json['chance_of_playing_next_round'],
        value_form: player_json['value_form']&.to_d,
        value_season: player_json['value_season']&.to_d,
        cost_change_start: player_json['cost_change_start'],
        cost_change_event: player_json['cost_change_event'],
        cost_change_start_fall: player_json['cost_change_start_fall'],
        cost_change_event_fall: player_json['cost_change_event_fall'],
        in_dreamteam: player_json['in_dreamteam'],
        dreamteam_count: player_json['dreamteam_count'],
        selected_by_percent: player_json['selected_by_percent']&.to_d,
        form: player_json['form']&.to_d,
        transfers_out: player_json['transfers_out'],
        transfers_in: player_json['transfers_in'],
        transfers_out_event: player_json['transfers_out_event'],
        transfers_in_event: player_json['transfers_in_event'],
        loans_in: player_json['loans_in'],
        loans_out: player_json['loans_out'],
        loaned_in: player_json['loaned_in'],
        loaned_out: player_json['loaned_out'],
        total_points: player_json['total_points'],
        event_points: player_json['event_points'],
        points_per_game: player_json['points_per_game']&.to_d,
        ep_this: player_json['ep_this']&.to_d,
        ep_next: player_json['ep_next']&.to_d,
        special: player_json['special'],
        minutes: player_json['minutes'],
        goals_scored: player_json['goals_scored'],
        goals_conceded: player_json['goals_conceded'],
        assists: player_json['assists'],
        clean_sheets: player_json['clean_sheets'],
        own_goals: player_json['own_goals'],
        penalties_missed: player_json['penalties_missed'],
        penalties_saved: player_json['penalties_saved'],
        yellow_cards: player_json['yellow_cards'],
        red_cards: player_json['red_cards'],
        saves: player_json['saves'],
        bonus: player_json['bonus'],
        bps: player_json['bps'],
        influence: player_json['influence']&.to_d,
        creativity: player_json['creativity']&.to_d,
        threat: player_json['threat']&.to_d,
        ict_index: player_json['ict_index']&.to_d,
        ea_index: player_json['ea_index'],
        position_id: player_json['element_type'],
        team_id: player_json['team'],
      )

      compose(
        Players::PopulateHistory,
        player: player,
      )
    end
  end
end
