class TeamDecorator < ApplicationDecorator
  def teams_hash
    Team.pluck_to_hash(
      :id,
      :name,
      :code,
      :short_name,
      :strength,
      :position,
      :played,
      :wins,
      :losses,
      :draws,
      :clean_sheets,
      :points,
      :form,
      :current_form,
      :goals_for,
      :goals_against,
      :goal_difference,
      :strength_overall_home,
      :strength_overall_away,
      :strength_attack_home,
      :strength_attack_away,
      :strength_defence_home,
      :strength_overall_away
    ).sort { |a, b| a[:id] <=> b[:id] }
  end

  def fixture_hash
    Fixture
      .joins('JOIN teams ON teams.id = fixtures.team_h_id OR teams.id = fixtures.team_a_id')
      .joins(
        'JOIN teams AS opponents ON (fixtures.team_h_id = teams.id AND fixtures.team_a_id = opponents.id) ' \
          'OR (fixtures.team_a_id = teams.id AND fixtures.team_h_id = opponents.id)'
      )
      .where(teams: { id: self.id })
      .order(:kickoff_time)
      .pluck_to_hash(
        :kickoff_time,
        'fixtures.id AS fixture_id',
        'opponents.id AS opponent_id',
        'opponents.short_name AS opponent_short_name',
        'opponents.name AS opponent_name',
        :team_h_id,
        :team_h_score,
        :team_a_score,
        :team_h_difficulty,
        :team_a_difficulty,
        :round_id,
      ).each_with_index do |hash, i|
      home_fixture = id == hash[:team_h_id]

      hash[:result] = form[i] if form.present?

      hash[:score] = "#{hash[:team_h_score]} - #{hash[:team_a_score]}"

      hash[:leg] = home_fixture ? 'H' : 'A'

      hash[:advantage] =
        if home_fixture
          hash[:team_a_difficulty] - hash[:team_h_difficulty]
        else
          hash[:team_h_difficulty] - hash[:team_a_difficulty]
        end

      hash
    end
  end
end
