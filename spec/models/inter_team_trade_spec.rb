# == Schema Information
#
# Table name: inter_team_trades
#
#  id                        :integer          not null, primary key
#  inter_team_trade_group_id :integer
#  out_player_id             :integer
#  in_player_id              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe InterTeamTrade, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
