class CreateLeaguesPlayersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :leagues, :players do |t|
      t.index :player_id
      t.index :league_id
    end
  end
end
