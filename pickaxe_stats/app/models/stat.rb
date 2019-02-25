# == Schema Information
#
# Table name: stats
#
#  id             :bigint(8)        not null, primary key
#  stat_delta     :integer
#  stat_key       :string           not null
#  stat_value     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  player_id      :integer          not null
#  weekly_stat_id :integer          not null
#

class Stat < ApplicationRecord
  belongs_to :week, class_name: "WeeklyStat", foreign_key: "weekly_stat_id"
  belongs_to :weekly_stat
  belongs_to :player

  def formated_value
    case self.stat_key
    when "stat.playOneMinute"
      stat_value / 20
    else
      stat_value
    end
  end
end
