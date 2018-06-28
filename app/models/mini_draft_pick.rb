# == Schema Information
#
# Table name: mini_draft_picks
#
#  id            :integer          not null, primary key
#  pick_number   :integer
#  season        :integer
#  passed        :boolean
#  league_id     :integer
#  out_player_id :integer
#  in_player_id  :integer
#  fpl_team_id   :integer
#  round_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class MiniDraftPick < ApplicationRecord
  belongs_to :league
  belongs_to :fpl_team
  belongs_to :out_player, class_name: 'Player', foreign_key: :out_player_id, optional: true
  belongs_to :in_player, class_name: 'Player', foreign_key: :in_player_id, optional: true
  belongs_to :round
  validates :pick_number, :season, presence: true
  validates :in_player, :out_player, presence: true, unless: :passed
  validates :in_player, :out_player, absence: true, if: :passed

  validates_uniqueness_of :pick_number, scope: [:league, :season]

  enum season: %w[summer winter]

  scope :completed, -> { where('passed IS TRUE OR (in_player_id IS NOT NULL AND out_player_id IS NOT NULL)') }
end
