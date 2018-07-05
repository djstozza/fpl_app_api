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

class InterTeamTrade < ApplicationRecord
  belongs_to :inter_team_trade_group
  belongs_to :out_player, class_name: 'Player', foreign_key: :out_player_id
  belongs_to :in_player, class_name: 'Player', foreign_key: :in_player_id
  validates_uniqueness_of :out_player, :in_player, scope: [:inter_team_trade_group_id]
end
