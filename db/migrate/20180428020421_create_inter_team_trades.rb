class CreateInterTeamTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :inter_team_trades do |t|
      t.references :inter_team_trade_group, index: true
      t.references :out_player, index: true, foreign_key: { to_table: :players }
      t.references :in_player, index: true, foreign_key: { to_table: :players }
      t.timestamps null: false
    end
  end
end
