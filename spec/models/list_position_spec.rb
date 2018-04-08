# == Schema Information
#
# Table name: list_positions
#
#  id               :integer          not null, primary key
#  fpl_team_list_id :integer
#  player_id        :integer
#  position_id      :integer
#  role             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe ListPosition, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
