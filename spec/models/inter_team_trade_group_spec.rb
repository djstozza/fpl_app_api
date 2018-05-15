# == Schema Information
#
# Table name: inter_team_trade_groups
#
#  id                   :integer          not null, primary key
#  out_fpl_team_list_id :integer
#  in_fpl_team_list_id  :integer
#  round_id             :integer
#  league_id            :integer
#  status               :integer          default("pending")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'rails_helper'

RSpec.describe InterTeamTradeGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
