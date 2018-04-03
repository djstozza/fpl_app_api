# == Schema Information
#
# Table name: leagues_players
#
#  league_id :integer          not null
#  player_id :integer          not null
#

class LeaguePlayer < ApplicationRecord
  self.table_name = :leagues_players
  belongs_to :league
  belongs_to :player
  validates_uniqueness_of :player_id, scope: :league_id
end
