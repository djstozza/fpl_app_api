class Leagues::UpdateLeagueForm < ApplicationInteraction
  object :user, class: User
  object :league, class: League

  model_fields :league do
    string :name
    string :code
  end

  validates :name, :code, presence: true
  validate :league_name_uniqueness
  validate :user_is_commissioner

  run_in_transaction!

  def execute
    league.assign_attributes(name: name, code: code)
    league.save
    errors.merge!(league.errors)
    league
  end

  private

  def league_name_uniqueness
    return if name == league.name
    if League.where('lower(name) = ?', name.downcase).count.positive?
      errors.add(:name, "has already been taken")
    end
  end

  def user_is_commissioner
    return if league.commissioner == user
    errors.add(:base, 'You are not authorised to edit this league.')
  end
end
