# == Schema Information
#
# Table name: draft_picks
#
#  id          :integer          not null, primary key
#  pick_number :integer
#  mini_draft  :boolean          default(FALSE)
#  league_id   :integer
#  player_id   :integer
#  fpl_team_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class DraftPick < ApplicationRecord
  belongs_to :league
  belongs_to :player, optional: true
  belongs_to :fpl_team
  delegate :user, to: :fpl_team

  validates :player, uniqueness: { scope: :league }, allow_blank: true
  validates :pick_number, presence: true, uniqueness: { scope: :league }

  validate :player_pick_or_mini_draft, on: :update

  private

  def player_pick_or_mini_draft
    errors.add(:player, "can't be blank") if player.blank? && !mini_draft
    errors.add(:base, "Either select a player or a mini draft pick") if player.present? && mini_draft
  end
end
