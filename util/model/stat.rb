class Stat < ActiveRecord::Base

  belongs_to :player
  belongs_to :weekly_stat

end
