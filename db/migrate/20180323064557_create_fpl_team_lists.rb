class CreateFplTeamLists < ActiveRecord::Migration[5.1]
  def change
    create_table :fpl_team_lists do |t|
      t.references :fpl_team, index: true
      t.references :round, index: true
      t.integer :total_score
      t.integer :rank
      t.timestamps null: false
    end
  end
end
