class CreateWaiverPicks < ActiveRecord::Migration[5.1]
  def change
    create_table :waiver_picks do |t|
      t.integer :pick_number
      t.integer :status, default: 0
      t.references :out_player, index: true, foreign_key: { to_table: :players }
      t.references :in_player, index: true, foreign_key: { to_table: :players }
      t.references :fpl_team_list, index: true
      t.references :round, index: true
      t.references :league, index: true
      t.timestamps null: false
    end
  end
end
