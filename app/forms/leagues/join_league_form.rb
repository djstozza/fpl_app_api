class Leagues::JoinLeagueForm < ApplicationInteraction
  object :user, class: User
  object :fpl_team, class: FplTeam, default: -> { FplTeam.new }

  string :name
  string :code
  string :fpl_team_name

  object :league, class: League, default: -> {
    League.find_by('lower(name) = :name AND code = :code', name: name, code: code)
  }

  validates :name, :fpl_team_name, :code, presence: true
  validate :league_presence
  validate :fpl_team_name_uniqueness
  validate :already_joined
  validate :max_fpl_team_quota
  validate :inactive_league

  run_in_transaction!

  def execute
    fpl_team.assign_attributes(name: fpl_team_name, user: user, league: league)
    fpl_team.save
    errors.merge!(fpl_team.errors)
    league
  end

  private

  def league_presence
    errors.add(:base, 'The league name and/or code you have entered is incorrect.') if league.blank?
  end


  def fpl_team_name_uniqueness
    return unless FplTeam.where('lower(name) = ?', fpl_team_name.downcase).count.positive?
    errors.add(:fpl_team_name, 'has already been taken.')
  end

  def already_joined
    return if league.nil?
    return unless league.users.include?(user)
    errors.add(:base, 'You have already joined this league.')
  end

  def max_fpl_team_quota
    return if league.nil?
    return if league.fpl_teams.count < League::MAX_FPL_TEAM_QUOTA
    errors.add(:base, 'The limit on fpl teams for this league has already been reached.')
  end

  def inactive_league
    return if league.nil?
    return unless league.active?
    errors.add(:base, 'You cannot join an activated league.')
  end
end
