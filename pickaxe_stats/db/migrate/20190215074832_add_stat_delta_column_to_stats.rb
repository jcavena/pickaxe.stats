class AddStatDeltaColumnToStats < ActiveRecord::Migration[5.2]
  def change
    add_column :stats, :stat_delta, :integer
  end
end
