class AddStatusToLeagues < ActiveRecord::Migration[5.1]
  def change
    remove_column :leagues, :active
    add_column :leagues, :status, :integer, default: 0
  end
end
