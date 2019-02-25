# == Schema Information
#
# Table name: players
#
#  id                        :bigint(8)        not null, primary key
#  name                      :string           not null
#  uuid                      :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  first_seen_weekly_stat_id :integer          not null
#  last_seen_weekly_stat_id  :integer          not null
#

class Player < ApplicationRecord
  belongs_to :first_seen, class_name: "WeeklyStat", foreign_key: "first_seen_weekly_stat_id"
  belongs_to :last_seen, class_name: "WeeklyStat", foreign_key: "last_seen_weekly_stat_id"

  has_many :stats

  has_many :weekly_stats, through: :stats
  
  def stats_for_week_of week_number
    stats = Stat.joins(:weekly_stat).where(stats: {player_id: self.id},
                                           weekly_stats: {week_number: week_number})
  end

  def stats_for stat_key
    stat = Stat.where(player_id: self.id, stat_key: stat_key).
             joins(:week).
             order("weekly_stats.commit_date desc")
  end

  def stat_for_week_of stat_key, week_number
    stat = Stat.joins(:weekly_stat).where(stats: {player_id: self.id,
                                                   stat_key: stat_key
                                               },
                                          weekly_stats: {week_number: week_number}).first
  end

  def stat_for_current stat_key
    most_recent_week = WeeklyStat.joins(:stats).
                            order(commit_date: :desc).
                            where(stats: { player_id: self.id,
                                           stat_key: stat_key}).first

    stat = most_recent_week.stats.
             where(stats: { player_id: self.id, stat_key: stat_key}).first

  end

  def stat_for_previous stat_key
    prev_most_recent_week = WeeklyStat.joins(:stats).
                              order(commit_date: :desc).
                              where(stats: { player_id: self.id,
                                             stat_key: stat_key}).second

    stat = prev_most_recent_week.stats.
             where(stats: { player_id: self.id, stat_key: stat_key}).first

  end

  def stat_delta stat_key
    current = stat_for_current stat_key
    previous = stat_for_previous stat_key

    current.formated_value - previous.formated_value 
  end

end
