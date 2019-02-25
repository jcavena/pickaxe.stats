class CreateStats < ActiveRecord::Migration[5.2]
  def change
    create_table :stats do |t|
      t.integer      :weekly_stat_id, null: false
      t.integer      :player_id, null: false
      t.string       :stat_key, null: false
      t.integer      :stat_value, null: true
      t.timestamps
    end
  end
end
