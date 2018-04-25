class ChangeTimeStringsToDatetime < ActiveRecord::Migration[5.1]
  def up
    change_column :fixtures, :deadline_time, 'timestamp USING CAST(deadline_time AS timestamp)'
    change_column :fixtures, :kickoff_time, 'timestamp USING CAST(kickoff_time AS timestamp)'
    change_column :rounds, :deadline_time, 'timestamp USING CAST(deadline_time AS timestamp)'
  end

  def down
    change_column :fixtures, :deadline_time, :string
    change_column :fixtures, :kickoff_time, :string
    change_column :rounds, :deadline_time, :string
  end
end
