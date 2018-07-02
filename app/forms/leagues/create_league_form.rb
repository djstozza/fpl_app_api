class Leagues::CreateLeagueForm < ApplicationInteraction
  object :user, class: User
  object :league, class: League, default: -> { League.new }
  object :fpl_team, class: FplTeam, default: -> { FplTeam.new }

  model_fields :league do
    string :name
    string :code
  end

  string :fpl_team_name

  validates :name, :code, :fpl_team_name, presence: true
  validate :league_name_uniqueness
  validate :fpl_team_name_uniqueness

  run_in_transaction!

  def execute
    league.assign_attributes(model_fields(:league).merge(commissioner: user))
    league.save
    errors.merge!(league.errors)

    fpl_team.assign_attributes(name: fpl_team_name, user: user, league: league)
    fpl_team.save
    errors.merge!(fpl_team.errors)

    league
  end

  def league_name_uniqueness
    return if name.blank?
    if League.where('lower(name) = ?', name.downcase).count.positive?
      errors.add(:name, "has already been taken")
    end
  end

  def fpl_team_name_uniqueness
    if FplTeam.where('lower(name) = ?', fpl_team_name.downcase).count.positive?
      errors.add(:fpl_team_name, "has already been taken")
    end
  end
end
