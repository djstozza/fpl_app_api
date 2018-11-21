class Teams::ProcessStats < ApplicationInteraction
  object :team, class: Team

  def execute
    team.update(
      wins: wins,
      losses: losses,
      draws: draws,
      clean_sheets: clean_sheets,
      goals_for: goals_for,
      goals_against: goals_against,
      goal_difference: (goals_for - goals_against),
      points: (wins * 3 + draws),
      played: fixtures.finished.count,
      form: form,
      current_form: current_form,
      position: position,
    )
    team
  end

  private

  def fixtures
    team.home_fixtures.or(team.away_fixtures).order(:round_id)
  end

  def wins
    fixtures_won.count
  end
   def losses
    fixtures_lost.count
  end

  def draws
    fixtures_drawn.count
  end

  def clean_sheets
    (home_clean_sheet_fixtures + away_clean_sheet_fixtures).count
  end

  def current_form
    form.last(5).join
  end

  def goals_for
    goal_calculator('team_h', 'team_a')
  end

  def goals_against
    goal_calculator('team_a', 'team_h')
  end

  def away_fixtures_won
    team.away_fixtures.finished.where('team_a_score > team_h_score')
  end

  def home_fixtures_won
    team.home_fixtures.finished.where('team_h_score > team_a_score')
  end

  def home_fixtures_lost
    team.home_fixtures.finished.where('team_a_score > team_h_score')
  end

  def away_fixtures_lost
    team.away_fixtures.finished.where('team_h_score > team_a_score')
  end

  def home_fixtures_drawn
    team.home_fixtures.finished.where('team_h_score = team_a_score')
  end

  def away_fixtures_drawn
    team.away_fixtures.finished.where('team_h_score = team_a_score')
  end

  def fixtures_won
    home_fixtures_won + away_fixtures_won
  end

  def fixtures_lost
    home_fixtures_lost + away_fixtures_lost
  end

  def fixtures_drawn
    home_fixtures_drawn + away_fixtures_drawn
  end

  def away_clean_sheet_fixtures
    team.away_fixtures.finished.where(team_h_score: 0)
  end

  def home_clean_sheet_fixtures
    team.home_fixtures.where(team_a_score: 0)
  end

  def form
    result_arr = []

    fixtures.finished.order(:round_id).each do |fixture|
      if fixtures_won.include?(fixture)
        result_arr << 'W'
      elsif fixtures_lost.include?(fixture)
        result_arr << 'L'
      elsif fixtures_drawn.include?(fixture)
        result_arr << 'D'
      end
    end

    result_arr
  end

  def goal_calculator(team_a, team_b)
    goals = 0

    team.home_fixtures.finished.each do |fixture|
      goals += fixture.public_send("#{team_a}_score")
    end

    team.away_fixtures.finished.each do |fixture|
      goals += fixture.public_send("#{team_b}_score")
    end

    goals
  end

  def position
    return if team.points.nil? || team.goal_difference.nil?

    ladder = Team.pluck(:points, :goal_difference).sort.reverse.uniq
    ladder.index([team.points, team.goal_difference]) + 1
  end
end
