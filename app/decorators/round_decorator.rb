class RoundDecorator < ApplicationDecorator
  def rounds_hash
    Round.pluck_to_hash(
      :id,
      :name,
      :deadline_time,
      :is_previous,
      :is_current,
      :is_next,
      :data_checked
    )
  end

  def fixture_hash
    fixtures.order(:kickoff_time).pluck_to_hash(
      :id,
      :kickoff_time,
      :stats,
      :team_h_id,
      :team_a_id,
      :team_h_score,
      :team_a_score,
      :team_h_difficulty,
      :team_a_difficulty,
      :round_id,
    )
  end
end
