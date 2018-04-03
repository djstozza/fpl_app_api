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
end
