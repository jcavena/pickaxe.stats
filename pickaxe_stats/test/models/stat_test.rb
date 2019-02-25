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

require 'test_helper'

class StatTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
