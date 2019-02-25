class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string        :uuid, null: false
      t.string        :name, null: false
      t.integer       :first_seen_weekly_stat_id, null: false
      t.integer       :last_seen_weekly_stat_id, null: false
      t.timestamps
    end
  end
end
