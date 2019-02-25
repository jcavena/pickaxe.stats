class CreateWeeklyStats < ActiveRecord::Migration[5.2]
  def change
    create_table :weekly_stats do |t|
      t.datetime      :commit_date, null: false
      t.string        :sha, null: false
      t.integer       :week_number, null: false
      t.string        :message, null: true
      t.string        :title, null: true
      t.integer       :player_count, default: 0, null: false
      t.timestamps
    end
  end
end
