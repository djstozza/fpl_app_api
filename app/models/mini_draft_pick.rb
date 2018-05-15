# == Schema Information
#
# Table name: mini_draft_picks
#
#  id            :integer          not null, primary key
#  pick_number   :integer
#  season        :integer
#  passed        :boolean
#  completed     :boolean
#  league_id     :integer
#  out_player_id :integer
#  in_player_id  :integer
#  fpl_team_id   :integer
#  round_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class MiniDraftPick < ApplicationRecord
end
