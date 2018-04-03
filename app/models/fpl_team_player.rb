# == Schema Information
#
# Table name: fpl_teams_players
#
#  fpl_team_id :integer          not null
#  player_id   :integer          not null
#

class FplTeamPlayer < ApplicationRecord
  self.table_name = :fpl_teams_players
  belongs_to :player
  belongs_to :fpl_team
  validates_uniqueness_of :player_id, scope: :fpl_team_id
end
