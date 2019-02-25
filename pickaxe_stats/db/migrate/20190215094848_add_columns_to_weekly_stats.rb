class AddColumnsToWeeklyStats < ActiveRecord::Migration[5.2]
  def change
    add_column :weekly_stats, :launched_at, :timestamp
    add_column :weekly_stats, :shutdown_at, :timestamp
    add_column :weekly_stats, :weekend_number, :integer
    add_column :weekly_stats, :notes, :string
  end
end
