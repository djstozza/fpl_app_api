# == Schema Information
#
# Table name: fpl_teams
#
#  id                     :integer          not null, primary key
#  name                   :string           not null
#  user_id                :integer
#  league_id              :integer
#  total_score            :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  draft_pick_number      :integer
#  mini_draft_pick_number :integer
#  rank                   :integer
#

class FplTeam < ApplicationRecord
  belongs_to :user
  belongs_to :league
  has_many :draft_picks
  has_many :mini_draft_picks
  has_and_belongs_to_many :players
  has_many :teams, through: :players
  has_many :fpl_team_lists
  has_many :waiver_picks, through: :fpl_team_lists

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :user, uniqueness: { scope: :league }
  validates :draft_pick_number, uniqueness: { scope: :league }, allow_nil: :true

  QUOTAS = { team: 3, goalkeepers: 2, midfielders: 5, defenders: 5, forwards: 3, players: 15 }.freeze
end
