class FplTeams::UpdateForm < ApplicationInteraction
  object :user, class: User
  object :fpl_team, class: FplTeam

  model_fields :fpl_team do
    string :name
  end

  validates :name, presence: true
  validate :fpl_team_name_uniqueness
  validate :user_owns_fpl_team

  run_in_transaction!

  def execute
    fpl_team.assign_attributes(name: name)
    fpl_team.save
    errors.merge!(fpl_team.errors)
    fpl_team
  end

  private

  def fpl_team_name_uniqueness
    return if name == fpl_team.name
    if FplTeam.where('lower(name) = ?', name.downcase).count.positive?
      errors.add(:name, "has already been taken")
    end
  end

  def user_owns_fpl_team
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to edit this league.')
  end
end
