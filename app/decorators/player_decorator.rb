class PlayerDecorator < ApplicationDecorator
  def name
    "#{first_name} #{last_name}"
  end

  def players_hash
    pluck_to_hash(
      :id,
      :first_name,
      :last_name,
      :photo,
      :status,
      :code,
      :news,
      :chance_of_playing_next_round,
      :chance_of_playing_this_round,
      :in_dreamteam,
      :dreamteam_count,
      :form,
      :total_points,
      :event_points,
      :points_per_game,
      :minutes,
      :goals_scored,
      :assists,
      :clean_sheets,
      :goals_conceded,
      :own_goals,
      :penalties_saved,
      :penalties_missed,
      :yellow_cards,
      :red_cards,
      :saves,
      :bonus,
      :bps ,
      :influence,
      :creativity,
      :threat,
      :ict_index,
      :open_play_crosses,
      :big_chances_created,
      :clearances_blocks_interceptions,
      :recoveries,
      :key_passes,
      :tackles,
      :winning_goals,
      :dribbles,
      :fouls,
      :errors_leading_to_goal,
      :offside,
      :position_id,
      :team_id,
    ).map do |hash|
      hash['status'] = status_class_hash[hash['status'].to_sym]
      hash
    end
  end


  private

  def status_class_hash
    {
      a: 'fa fa-check-circle',
      d: 'fa fa-question-circle',
      i: 'fa fa-ambulance',
      n: 'fa fa-times-circle',
      s: 'fa fa-gavel',
      u: 'fa fa-times-circle',
    }
  end
end
