require 'active_record'
require 'dotenv/load'
require 'logger'


ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Schema.define do
  self.verbose = true

  enable_extension 'plpgsql'
  enable_extension 'pgcrypto'

  create_table(:weekly_stats, force: true) do |t|
    t.datetime      :commit_date, null: false
    t.string        :sha, null: false
    t.datetime      :created_at, null: false
    t.datetime      :updated_at, null: false
    t.integer       :week_number, null: false
    t.string        :message, null: true
    t.string        :title, null: true
    t.integer       :player_count, default: 0, null: false
  end

  create_table(:players, force: true) do |t|
    t.string        :uuid, null: false
    t.string        :name, null: false
    t.integer       :first_seen_weekly_stat_id, null: false
    t.integer       :last_seen_weekly_stat_id, null: false
    t.datetime      :created_at, null: false
    t.datetime      :updated_at, null: false
  end

  create_table(:stats, force: true) do |t|
    t.integer      :weekly_stat_id, null: false
    t.integer      :player_id, null: false
    t.string       :stat_key, null: false
    t.integer      :stat_value, null: true
    t.datetime     :created_at, null: false
    t.datetime     :updated_at, null: false
  end
end
