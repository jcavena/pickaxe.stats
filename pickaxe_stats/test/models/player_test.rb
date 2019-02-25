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

require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
