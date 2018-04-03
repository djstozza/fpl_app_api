class CreateFplTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :fpl_teams do |t|
      t.string :name, null: false
      t.references :user, index: true
      t.references :league, index: true
      t.integer :total_score
      t.timestamps null: false
    end

    add_index :fpl_teams, :name, unique: true
  end
end
