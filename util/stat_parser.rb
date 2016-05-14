require 'benchmark'
# http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html 
require 'open-uri'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

require_relative 'constants.rb'
require_relative 'helpers.rb'



def get_player_list
  buffer = nil
  if @local == true
    buffer = File.open(LOCAL_USER_CACHE_PATH).read
  else
    request_uri = USER_CACHE_URI
    url = "#{request_uri}"
    # Actually fetch the contents of the remote URL as a String.
    buffer = open(url).read
  end
  JSON.parse(buffer).sort_by{|hash| hash['name'].downcase}
end

def get_player_data(player)
  buffer = nil
  if @local == true
    buffer = File.open(LOCAL_USER_TEMPLATE_PATH.gsub("UUID", player['uuid'])).read
  else
    request_uri = USER_URI_TEMPLATE.gsub("UUID", player['uuid'])
    url = "#{request_uri}"
    buffer = open(url).read
  end
  JSON.parse(buffer)
end

def generate_player_stats_csv(player_list)
  # CSV friendly version. Just printing to console and saving manually. Should just save to csv file instead.    
  # leave in when doing the CSV version, match up the names to the stats. Comment out when doing the other versions.
  puts 'Name,Time Killed,Deaths,Mobs Killed,Players Killed,Villagers Killed,Pigmen Killed,Ghast Killed,Horses Killed,Seconds Played'

  player_list.each do |player|
    begin
      result = get_player_data player
      puts "#{player['name']},#{humanize(result['stat.playOneMinute'].to_i / 20)},#{result['stat.deaths'].to_i },#{result['stat.playerKills'].to_i},#{result['stat.mobKills'].to_i},#{result['stat.killEntity.Villager'].to_i},#{result['stat.killEntity.PigZombie'].to_i},#{result['stat.killEntity.Ghast'].to_i},#{result['stat.killEntity.EntityHorse'].to_i},#{result['stat.playOneMinute'].to_i / 20}"
    rescue 
      #sometimes there is no matching json file.
    end
  end
end

def generate_kill_stats(player_list)
  template = File.open('template.html').read
  rows = []
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
      row << ["#{player['name']}",
                "#{result['stat.damageDealt'].to_i}",
                "#{result['stat.damageTaken'].to_i}",
                "#{result['stat.deaths'].to_i }",
                "#{(result['stat.playOneMinute'].to_i / 20) / (result['stat.deaths'].to_i + 1)}t",
                "#{result['stat.playerKills'].to_i}"]
      KILLENTITY_KEYS.each do |key|
        row << "#{result[key].to_i}"
        if KILLEDBY_KEYS.include? key.gsub('killEntity','entityKilledBy')
          row << "#{result[key.gsub('killEntity','entityKilledBy')].to_i}"
        end
      end

      rows << row.flatten
    rescue 
      #sometimes there is no matching json file.
    end
  end
  content = kill_stats_table(rows)

  File.open('../kills.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_adventuring_time(player_list)
  template = File.open('template.html').read
  rows = []
  biomes_denominator = ADVENTURING_TIME_BIOMES.length.to_f
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
      adventuring_time = result['achievement.exploreAllBiomes']['value'].to_s == "1"
      explored_adventuring_time_biomes = result['achievement.exploreAllBiomes']['progress'] & ADVENTURING_TIME_BIOMES
      row = ["#{player['name']}",
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

  File.open('../adventuring_time.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_achievements(player_list)
  template = File.open('template.html').read
  rows = []
  achivements_denominator = ACHIEVEMENTS.length.to_f
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
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
      row = ["#{player['name']}",
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

  File.open('../achievements.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_travel_stats(player_list)
  template = File.open('template.html').read
  rows = []
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
       row << "#{player['name']}"
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

  File.open('../travel.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_general_stats(player_list)
  template = File.open('template.html').read
  rows = []
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
      row << "#{player['name']}"
      GENERAL_STATS_KEYS.each do |key|
        if ['stat.playOneMinute', 'stat.timeSinceDeath', 'stat.sneakTime'].include? key
          row << "#{result[key].to_i / 20}t"
        else
          row << "#{result[key].to_i}"
        end
      end
      rows << row.flatten
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = general_stats_table(rows)

  File.open('../index.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_crafting_stats(player_list)
  template = File.open('template.html').read
  rows = []
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
      row << "#{player['name']}"
      row << '0'

      crafted_total = 0
      CRAFTING_KEYS.each do |key|
        crafted_amount = result[key].to_i
        crafted_total += crafted_amount unless key == 'stat.craftingTableInteraction'
        row << "#{crafted_amount}"
      end

      row = row.flatten
      row[1] = crafted_total
      rows << row
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = crafted_stats_table(rows)

  File.open('../crafting.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_mining_stats(player_list)
  template = File.open('template.html').read
  rows = []
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
      row << "#{player['name']}"
      row << '0'

      mined_total = 0
      MINING_KEYS.each do |key|
        mined_amount = result[key].to_i
        mined_total += mined_amount
        row << "#{mined_amount}"
      end

      row = row.flatten
      row[1] = mined_total
      rows << row
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = mined_stats_table(rows)

  File.open('../mining.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_food_stats(player_list)
  template = File.open('template.html').read
  rows = []
  
  player_list.each do |player|
    row = []
    begin
      result = get_player_data player
      row << "#{player['name']}"
      row << '0'
      food_total = 0
      FOOD_KEYS.each do |key|
        food_amount = result[key].to_i
        food_total += food_amount
        row << "#{food_amount}"
      end

      row = row.flatten
      row[1] = food_total
      rows << row
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = food_stats_table(rows)

  File.open('../food.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end


def generate_bubble_stats(player_list, key, threshold = 0)
  rows = {}
  player_list.each do |user|
    begin
      result = get_player_data player
      if ['stat.playOneMinute', 'stat.timeSinceDeath', 'stat.sneakTime'].include? key
        value = result[key].to_i / 20
      else
        value = result[key]
      end
      next if value < threshold
      rows[user['name']] = value
    rescue 
      #sometimes there is no matching json file.
    end
  end

  #content = general_stats_table(rows)
  puts "STATS FOR #{key}"
  puts rows.to_json

end

@local = true

time = Benchmark.measure do

  player_list = get_player_list #.sample(10)


  # puts 'generating bubble stats'
  # generate_bubble_stats(player_list, 'stat.timeSinceDeath', 3600)
  # puts 'finished generating bubble stats'

  puts "GENERATING KILL STATS PAGE..."
  generate_kill_stats(player_list)
  puts "FINISHED GENERATING KILL STATS PAGE..."

  puts "GENERATING ADVENTURING TIME PAGE..."
  generate_adventuring_time(player_list)
  puts "FINISHED GENERATING ADVENTURING TIME PAGE..."

  puts "GENERATING ACHIEVEMENTS PAGE..."
  generate_achievements(player_list)
  puts "FINISHED GENERATING ACHIEVEMENTS PAGE..."

  puts "GENERATING TRAVEL PAGE..."
  generate_travel_stats(player_list)
  puts "FINISHED GENERATING TRAVEL PAGE..."

  puts "GENERATING CRAFTING PAGE..."
  generate_crafting_stats(player_list)
  puts "FINISHED GENERATING CRAFTING PAGE..."

  puts "GENERATING MINING PAGE..."
  generate_mining_stats(player_list)
  puts "FINISHED GENERATING MINING PAGE..."

  puts "GENERATING FOOD PAGE..."
  generate_food_stats(player_list)
  puts "FINISHED GENERATING FOOD PAGE..."

  puts "GENERATING GENERAL STATS PAGE..."
  generate_general_stats(player_list)
  puts "FINISHED GENERATING GENERAL STATS PAGE..."
end

puts "Time elapsed: #{time}"
