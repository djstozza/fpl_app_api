class AddOverallRankToFplTeamLists < ActiveRecord::Migration[5.1]
  def change
    add_column :fpl_team_lists, :overall_rank, :integer
  end
end
