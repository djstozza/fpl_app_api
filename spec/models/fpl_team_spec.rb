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
#

require 'rails_helper'

RSpec.describe FplTeam, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
