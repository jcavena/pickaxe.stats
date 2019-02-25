# == Schema Information
#
# Table name: weekly_stats
#
#  id             :bigint(8)        not null, primary key
#  commit_date    :datetime         not null
#  launched_at    :datetime
#  message        :string
#  notes          :string
#  player_count   :integer          default(0), not null
#  sha            :string           not null
#  shutdown_at    :datetime
#  title          :string
#  week_number    :integer          not null
#  weekend_number :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class WeeklyStatTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
