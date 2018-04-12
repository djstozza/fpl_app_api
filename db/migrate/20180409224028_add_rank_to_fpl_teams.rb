class AddRankToFplTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :fpl_teams, :rank, :integer
  end
end
