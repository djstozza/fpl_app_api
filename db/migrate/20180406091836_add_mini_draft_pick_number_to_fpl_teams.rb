class AddMiniDraftPickNumberToFplTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :fpl_teams, :mini_draft_pick_number, :integer
  end
end
