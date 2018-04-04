# == Schema Information
#
# Table name: fpl_teams
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  user_id           :integer
#  league_id         :integer
#  total_score       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  draft_pick_number :integer
#

class FplTeam < ApplicationRecord
  belongs_to :user
  belongs_to :league
  has_many :draft_picks
  has_and_belongs_to_many :players
  has_many :teams, through: :players

  QUOTAS = { team: 3, goalkeepers: 2, midfielders: 5, defenders: 5, forwards: 3, players: 15 }.freeze
end
