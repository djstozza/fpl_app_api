class AddDraftPickNumberToFplTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :fpl_teams, :draft_pick_number, :integer
  end
end
