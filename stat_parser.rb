# http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html 
require 'open-uri'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

require_relative 'constants.rb'
require_relative 'helpers.rb'

def get_player_list
  request_uri = USER_CACHE_URI
  url = "#{request_uri}"

  # Actually fetch the contents of the remote URL as a String.
  buffer = open(url).read
  player_list = JSON.parse(buffer).sort_by{|hash| hash['name'].downcase}

end

def generate_player_stats_csv(player_list)
  # CSV friendly version. Just printing to console and saving manually. Should just save to csv file instead.    
  # leave in when doing the CSV version, match up the names to the stats. Comment out when doing the other versions.
  puts 'Name,Time Killed,Deaths,Mobs Killed,Players Killed,Villagers Killed,Pigmen Killed,Ghast Killed,Horses Killed,Seconds Played'

  player_list.each do |user|
    request_uri = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    url = "#{request_uri}"

    begin
      buffer = open(url).read
      result = JSON.parse(buffer)

      puts "#{user['name']},#{humanize(result['stat.playOneMinute'].to_i / 20)},#{result['stat.deaths'].to_i },#{result['stat.playerKills'].to_i},#{result['stat.mobKills'].to_i},#{result['stat.killEntity.Villager'].to_i},#{result['stat.killEntity.PigZombie'].to_i},#{result['stat.killEntity.Ghast'].to_i},#{result['stat.killEntity.EntityHorse'].to_i},#{result['stat.playOneMinute'].to_i / 20}"
    rescue 
      #sometimes there is no matching json file.
      #puts "#{user['name']},0,0,0,0,0,0,0,0"
    end

  end
end

def generate_kill_stats(player_list)
  template = File.open('template.html').read
  #GENERATE KILL STATS PAGE (index.html)
  rows = []
  
  #'Name,Time Killed,Deaths,Players Killed, KILLENTITY_KEYS*'
  player_list.each do |user|
    request_uri = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    url = "#{request_uri}"

    row = []
    begin
      buffer = open(url).read
      result = JSON.parse(buffer)
      row << ["#{user['name']}",
                "#{result['stat.playOneMinute'].to_i / 20}",
                "#{result['stat.deaths'].to_i }",
                "#{(result['stat.playOneMinute'].to_i / 20) / (result['stat.deaths'].to_i + 1)}",
                "#{result['stat.playerKills'].to_i}"]
      KILLENTITY_KEYS.each do |key|
        row << "#{result[key].to_i}"
      end

      rows << row.flatten
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = kill_stats_table(rows)

  File.open('index.html', 'w'){ |file| file.write template.gsub('<user_content>',content)}
end

def generate_adventuring_time(player_list)
  template = File.open('template.html').read
  rows = []
  biomes_denominator = ADVENTURING_TIME_BIOMES.length.to_f
  
  player_list.each do |user|
    url = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    row = []
    begin
      buffer = open(url).read
      result = JSON.parse(buffer)
      adventuring_time = result['achievement.exploreAllBiomes']['value'].to_s == "1"
      explored_adventuring_time_biomes = result['achievement.exploreAllBiomes']['progress'] & ADVENTURING_TIME_BIOMES

      row = ["#{user['name']}",
              "#{adventuring_time ? "Yes" : "No"}",
              "#{result['achievement.exploreAllBiomes']['progress'].sort.join(", ")}",
              "#{(ADVENTURING_TIME_BIOMES - explored_adventuring_time_biomes).sort.join(", ")}",
              explored_adventuring_time_biomes.length.to_f / biomes_denominator
              ]
      rows << row
    rescue 
      #no matching stats file
    end
  end
  content = adventuring_time_table(rows)

  File.open('adventuring_time.html', 'w'){ |file| file.write template.gsub('<user_content>',content)}
  
end

def generate_achievements(player_list)
  template = File.open('template.html').read
  rows = []
  achivements_denominator = ACHIEVEMENTS.length.to_f
  
  player_list.each do |user|
    url = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    row = []
    begin
      buffer = open(url).read
      result = JSON.parse(buffer)
      completed_achievements = []
      remaining_achievements = []
      ACHIEVEMENTS.keys.each do |achievement|
        if achievement == 'achievement.exploreAllBiomes' 
          if result[achievement]['value'].to_s == "1"
            completed_achievements << achievement
          end
        elsif result[achievement] && result[achievement].to_i > 0
          completed_achievements << achievement
        end
      end
      remaining_achievements = (ACHIEVEMENTS.keys - completed_achievements)
      row = ["#{user['name']}",
              "#{completed_achievements.map{|key| ACHIEVEMENTS[key]}.join(", ")}",
              "#{remaining_achievements.map{|key| ACHIEVEMENTS[key]}.join(", ")}",
              "#{completed_achievements.length.to_f / achivements_denominator}"
              ]
      rows << row
    rescue 
      #no matching stats file
    end
  end
  content = achievements_table(rows)

  File.open('achievements.html', 'w'){ |file| file.write template.gsub('<user_content>',content)}
  
end

def generate_travel_stats(player_list)
  template = File.open('template.html').read
  #GENERATE KILL STATS PAGE (index.html)
  
  rows = []
  
  #'Name,Time Killed,Deaths,Players Killed, KILLENTITY_KEYS*'
  player_list.each do |user|
    request_uri = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    url = "#{request_uri}"

    row = []
    begin
      buffer = open(url).read
      result = JSON.parse(buffer)
       row << "#{user['name']}"
       row << '0'

        travel_total = 0
        TRAVEL_KEYS.each do |key|
          key_travel_total = result[key].to_i
          travel_total += key_travel_total
          row << "#{key_travel_total}"
        end

        row = row.flatten
        row[1] = travel_total
        rows << row

    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = travel_stats_table(rows)

  File.open('travel.html', 'w'){ |file| file.write template.gsub('<user_content>',content)}
end

player_list = get_player_list

# puts "GENERATING KILL STATS PAGE..."
# generate_kill_stats(player_list)
# puts "FINISHED GENERATING KILL STATS PAGE..."

# puts "GENERATING ADVENTURING TIME PAGE..."
# generate_adventuring_time(player_list)
# puts "FINISHED GENERATING ADVENTURING TIME PAGE..."

# puts "GENERATING ACHIEVEMENTS PAGE..."
# generate_achievements(player_list)
# puts "FINISHED GENERATING ACHIEVEMENTS PAGE..."

puts "GENERATING TRAVEL PAGE..."
generate_travel_stats(player_list)
puts "FINISHED GENERATING TRAVEL PAGE..."

