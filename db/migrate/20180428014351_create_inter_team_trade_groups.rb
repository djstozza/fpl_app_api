class CreateInterTeamTradeGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :inter_team_trade_groups do |t|
      t.references :out_fpl_team_list, index: true, foreign_key: { to_table: :fpl_team_lists }
      t.references :in_fpl_team_list, index: true, foreign_key: { to_table: :fpl_team_lists }
      t.references :round, index: true
      t.references :league, index: true
      t.integer :status, default: 0
      t.timestamps null: false
    end
  end
end
