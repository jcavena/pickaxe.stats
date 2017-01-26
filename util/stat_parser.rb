require 'benchmark'
# http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html 
require 'open-uri'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

require_relative 'constants.rb'
require_relative 'helpers.rb'

def get_player_list(which_week = 'current')
  buffer = nil
  if @local == true
    buffer = File.open(Object.const_get("LOCAL_#{which_week.upcase}_USER_CACHE_PATH")).read
  else
    request_uri = USER_CACHE_URI
    url = "#{request_uri}"
    # Actually fetch the contents of the remote URL as a String.
    buffer = open(url).read
  end
  JSON.parse(buffer).sort_by{|hash| hash['name'].downcase}
end

def get_player_data(player, which_week = 'current')
  buffer = nil
  if @local == true
    buffer = File.open(Object.const_get("LOCAL_#{which_week.upcase}_USER_TEMPLATE_PATH").gsub("UUID", player['uuid'])).read
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
                "#{result['stat.damageDealt'].to_i / 10}",
                "#{result['stat.damageTaken'].to_i / 10}",
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
              explored_adventuring_time_biomes.length.to_f / biomes_denominator,
              "#{ADVENTURING_TIME_BIOMES.sort.join(",")}"
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
              "#{completed_achievements.length.to_f / achivements_denominator}",
              "#{ACHIEVEMENTS.values.join(",")}"
              ]
      rows << row
    rescue 
      #no matching stats file
    end
  end
  content = achievements_table(rows)

  File.open('../achievements.html', 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def generate_travel_stats
  rows = []
  
  @player_data.each do |player|
    row = {}
    begin
      row['name'] = "#{player['name']}"
      row['travel_total'] = 0
      row['previous_travel_total'] = 0
      current_travel_total = 0
      previous_travel_total = 0
      TRAVEL_KEYS.each do |key|
        current_travel_total += player['current_stats'][key].to_i
        row['current.' + key] = player['current_stats'][key].to_i
        previous_travel_total += player['previous_stats'][key].to_i
        row['previous.' + key] = player['previous_stats'][key].to_i
      end
      row['current.travel_total'] = current_travel_total
      row['previous.travel_total'] = previous_travel_total
      rows << row

    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = travel_stats_table(rows)
  generate_file('../travel.html', content)
  
end

def generate_general_stats
  rows = []
  
  @player_data.each do |player|
    row = {}
    begin
      row['name'] = "#{player['name']}"
      row['uuid'] = "#{player['uuid']}"
      GENERAL_STATS_KEYS.each do |key|
        if ['stat.playOneMinute', 'stat.timeSinceDeath', 'stat.sneakTime'].include? key
          row['current.' + key] = "#{player['current_stats'][key].to_i / 20}t"
          row['previous.' + key] = "#{player['previous_stats'][key].to_i / 20}t"
        elsif ['stat.damageDealt', 'stat.damageTaken'].include? key
          row['current.' + key] = "#{player['current_stats'][key].to_i / 10}"
          row['previous.' + key] = "#{player['previous_stats'][key].to_i / 10}"
        else
          row['current.' + key] = "#{player['current_stats'][key].to_i}"
          row['previous.' + key] = "#{player['previous_stats'][key].to_i}"
        end
      end
      rows << row #.flatten
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = general_stats_table(rows)
  generate_file('../index.html', content)
end

def generate_crafting_stats#(player_list)
  rows = []
  
  @player_data.each do |player|
    row = {}
    begin
      row['name'] = "#{player['name']}"
      row['crafted_total'] = 0
      row['previous_crafted_total'] = 0
      current_crafted_total = 0
      previous_crafted_total = 0
      CRAFTING_KEYS.each do |key|
        current_crafted_total += player['current_stats'][key].to_i
        row['current.' + key] = player['current_stats'][key].to_i
        previous_crafted_total += player['previous_stats'][key].to_i
        row['previous.' + key] = player['previous_stats'][key].to_i
      end
      row['current.crafted_total'] = current_crafted_total
      row['previous.crafted_total'] = previous_crafted_total
      rows << row

    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = crafted_stats_table(rows)
  generate_file('../crafting.html', content)
  
end

def generate_mining_stats#(player_list)
  rows = []
  
  @player_data.each do |player|
    row = {}
    begin
      row['name'] = "#{player['name']}"
      row['mined_total'] = 0
      row['previous_mined_total'] = 0
      current_mined_total = 0
      previous_mined_total = 0
      MINING_KEYS.each do |key|
        current_mined_total += player['current_stats'][key].to_i
        row['current.' + key] = player['current_stats'][key].to_i
        previous_mined_total += player['previous_stats'][key].to_i
        row['previous.' + key] = player['previous_stats'][key].to_i
      end
      row['current.mined_total'] = current_mined_total
      row['previous.mined_total'] = previous_mined_total
      rows << row

    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = mined_stats_table(rows)

  generate_file('../mining.html', content)
end

def generate_food_stats#(player_list)
  rows = []
  
  @player_data.each do |player|
    row = {}
    begin
      row['name'] = "#{player['name']}"
      row['food_total'] = 0
      row['previous_food_total'] = 0
      current_food_total = 0
      previous_food_total = 0
      FOOD_KEYS.each do |key|
        current_food_total += player['current_stats'][key].to_i
        row['current.' + key] = player['current_stats'][key].to_i
        previous_food_total += player['previous_stats'][key].to_i
        row['previous.' + key] = player['previous_stats'][key].to_i
      end

      row['current.food_total'] = current_food_total
      row['previous.food_total'] = previous_food_total
      rows << row
    rescue 
      #sometimes there is no matching json file.
    end
  end

  content = food_stats_table(rows)
  generate_file('../food.html', content)

end

def generate_grand_total_stats(player_list, keys = [])

  if keys.empty?
    keys += GENERAL_STATS_KEYS
    keys += TRAVEL_KEYS
    keys += FOOD_KEYS
    keys += KILLENTITY_KEYS
    keys += KILLEDBY_KEYS
    keys += MINING_KEYS
    keys += CRAFTING_KEYS
    
    #keys += ACHIEVEMENT_KEYS
    #keys += BIOMES
  end  

  rows = []
  
  player_list.each do |player|
    begin
      rows << get_player_data(player)
    rescue 
      #sometimes there is no matching json file.
    end
  end

  keys.each do |key|
    total_val = 0
    rows.each do |row|
      total_val += row[key].to_i
    end

    if ['stat.playOneMinute', 'stat.timeSinceDeath', 'stat.sneakTime'].include? key
      total_val = humanize_time total_val.to_i / 20
    elsif key =~ /onecm/i
      total_val = humanize_distance total_val
    end

    puts "#{pretty_label key} Total: #{total_val}"
  end
end

def generate_bubble_stats(player_list, key, threshold = 0)
  rows = {}
  player_list.each do |player|
    begin
      result = get_player_data player
      if ['stat.playOneMinute', 'stat.timeSinceDeath', 'stat.sneakTime'].include? key
        value = result[key].to_i / 20
      else
        value = result[key]
      end
      next if value < threshold
      rows[player['name']] = value
    rescue 
      #sometimes there is no matching json file.
    end
  end

  #content = general_stats_table(rows)
  puts "STATS FOR #{key}"
  puts rows.to_json
end

def generate_file(file_name, content)
  template = File.open('template.html').read  
  File.open(file_name, 'w'){ |file| file.write template.gsub('<player_content>',content)}
end

def load_all_player_data
  @player_data = get_player_list

  @player_data.each do |player|
    player['previous_stats'] = get_player_data player, 'previous' rescue nil
    player['current_stats'] = get_player_data player rescue nil

    if player['previous_stats'].nil?
      puts "#{player['name']} has no previous stats"
    end
    if player['current_stats'].nil?
      puts "#{player['name']} has no current stats"
    end
  end
  
  # puts @player_data

end

@local = true
@player_data = {}

time = Benchmark.measure do

  player_list = get_player_list #.sample(10)

  load_all_player_data
  
  #puts @player_data

  # puts "Player Count: #{player_list.size}"

  puts 'generating grand total stats'
  generate_grand_total_stats(player_list)
  puts 'finished generating grand total stats'

  # puts 'generating bubble stats'
  # generate_bubble_stats(player_list, 'stat.playOneMinute', 0)
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
  generate_travel_stats #(player_list)
  puts "FINISHED GENERATING TRAVEL PAGE..."

  puts "GENERATING CRAFTING PAGE..."
  generate_crafting_stats #(player_list)
  puts "FINISHED GENERATING CRAFTING PAGE..."

  puts "GENERATING MINING PAGE..."
  generate_mining_stats #(player_list)
  puts "FINISHED GENERATING MINING PAGE..."

  puts "GENERATING FOOD PAGE..."
  generate_food_stats #(player_list)
  puts "FINISHED GENERATING FOOD PAGE..."

  puts "GENERATING GENERAL STATS PAGE..."
  generate_general_stats #(player_list)
  puts "FINISHED GENERATING GENERAL STATS PAGE..."

end

puts "Time elapsed: #{time}"
