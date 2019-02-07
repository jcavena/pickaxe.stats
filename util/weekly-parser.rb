require 'git'
require 'active_record'
require 'dotenv/load'
require 'logger'

require 'json'

require_relative 'helpers.rb'
require_relative 'constants.rb'
require_relative 'model/weekly_stat.rb'
require_relative 'model/player.rb'
require_relative 'model/stat.rb'



def process_this_week commit, week_number
  start_time = Time.now
  puts "\t\tprocess_this_week begin #{commit.date} #{week_number} - #{start_time}\n"

  player_list = get_player_list

  w = WeeklyStat.new
  w.commit_date = commit.date
  w.week_number = week_number
  w.sha = commit.sha
  w.message = commit.message
  w.player_count = player_list.count
  w.save


  print "\t\t\t"

  player_list.each do |player_data|
    p = Player.where(uuid: player_data['uuid']).first

    if p
      print "U"
      # puts "\t\t\tPlayer #{player_data['name']} exists, updating."
      p.last_seen_weekly_stat_id = w.id
      p.save
    else
      print "c"
      # puts "\t\t\tPlayer #{player_data['name']} does not exist, creating."
      p = Player.new
      p.name = player_data['name']
      p.uuid = player_data['uuid']
      p.first_seen_weekly_stat_id = w.id
      p.last_seen_weekly_stat_id = w.id
      p.save
    end

    process_player p, w

  end
  end_time = Time.now
  duration = end_time - start_time
  
  puts "\n\t\tprocess_this_week end #{commit.date} #{week_number} #{end_time}\n"
  puts "Processing Time: #{duration}\n"
end

def get_player_list
  buffer = nil
  buffer = File.open(LOCAL_CURRENT_USER_CACHE_PATH).read

  JSON.parse(buffer).sort_by{|hash| hash['name'].downcase}
end

def get_player_data(player)
  buffer = nil
  player_stat_file = LOCAL_CURRENT_USER_TEMPLATE_PATH.gsub("UUID", player.uuid)
  # puts "\t\t\t\t#{player_stat_file} for #{player.name}"
  begin
    buffer = File.open(player_stat_file).read
  rescue

  end
  JSON.parse(buffer)
end

def process_player player, weekly_stat
  stats = get_player_data player

  # puts stats

  stats.each do |stat_data|
    s = Stat.new
    s.player = player
    s.weekly_stat = weekly_stat
    s.stat_key = stat_data[0]
    s.stat_value = stat_data[1]
    s.save
  end
end

ActiveRecord::Base.logger = Logger.new(ENV['LOG_FILE'])

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

g = Git.open("../../pickaxe.club")

puts g.repo

counter = 0
prev_date = nil
index = 0
sleep_duration = 1


puts "Pulling #{g.repo}"
g.pull

puts 'Getting commit log...'
commits = g.log(300)

puts "There are #{commits.count}"

puts 'Enumerating commits'

commits.reverse_each do |commit|
  index += 1

  if commit.message =~ /final/
    # this is a potential weekly stats commit
    counter += 1
    if prev_date
      days_since_last = ((commit.date - prev_date) / 60 / 60 / 24).to_i
    end
    puts "\t#{commits.count - index}\t#{counter + 3}\t#{days_since_last}\t#{commit.sha} \t#{commit.message[0..20].ljust 23} \t#{commit.date}\t#{commit.author.name} "
    prev_date = commit.date

    # reset head

    check_for = "#{g.repo}/index.lock"

    puts "\t\tChecking for #{check_for}"

    if File.exists?(check_for)
      puts "\t\tsleeping for #{sleep_duration} second"
      sleep sleep_duration
    end

    puts "\t\tReseting to #{commit.sha}"
    g.reset_hard commit

    week = counter + 3
    process_this_week commit, week

  end

end
