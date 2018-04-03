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

require 'rails_helper'

RSpec.describe DraftPick, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
