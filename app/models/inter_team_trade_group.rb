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
  belongs_to :league
  belongs_to :round
  belongs_to :out_fpl_team_list, class_name: 'FplTeamList', foreign_key: :out_fpl_team_list_id
  belongs_to :in_fpl_team_list, class_name: 'FplTeamList', foreign_key: :in_fpl_team_list_id

  delegate :fpl_team, to: :in_fpl_team_list, prefix: :in
  delegate :fpl_team, to: :out_fpl_team_list, prefix: :out

  has_many :inter_team_trades, dependent: :destroy
  has_many :in_players, class_name: 'Player', foreign_key: :in_player_id, through: :inter_team_trades
  has_many :out_players, class_name: 'Player', foreign_key: :out_player_id, through: :inter_team_trades

  enum status: { pending: 0, submitted: 1, approved: 2, declined: 3, expired: 4 }
end
