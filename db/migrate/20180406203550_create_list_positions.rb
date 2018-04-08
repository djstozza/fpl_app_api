class CreateListPositions < ActiveRecord::Migration[5.1]
  def change
    create_table :list_positions do |t|
      t.references :fpl_team_list, index: true
      t.references :player, index: true
      t.references :position, index: true
      t.integer :role
      t.timestamps null: false
    end
  end
end
