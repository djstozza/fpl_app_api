# == Schema Information
#
# Table name: leagues
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  code            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  commissioner_id :integer
#  status          :integer          default("generate_draft_picks")
#

class League < ApplicationRecord
  MIN_FPL_TEAM_QUOTA = 8
  MAX_FPL_TEAM_QUOTA = 11

  belongs_to :commissioner, class_name: 'User', foreign_key: 'commissioner_id'
  has_many :draft_picks

  validates :name, :code, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  has_many :fpl_teams
  has_many :fpl_team_lists, through: :fpl_teams
  has_many :users, through: :fpl_teams
  has_and_belongs_to_many :players
  has_many :waiver_picks

  enum status: { generate_draft_picks: 0, create_draft: 1, draft: 2, active: 3 }
end
