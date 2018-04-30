# == Schema Information
#
# Table name: inter_team_trade_groups
#
#  id                   :integer          not null, primary key
#  out_fpl_team_list_id :integer
#  in_fpl_team_list_id  :integer
#  round_id             :integer
#  league_id            :integer
#  status               :integer          default(0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class InterTeamTradeGroup < ApplicationRecord
end
