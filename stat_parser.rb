#mode = 'adventuring_time'
#mode = 'player_stats.csv'
mode = 'player_stats.html'


# http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html 
require 'open-uri'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

require_relative 'helpers.rb'


# Construct the URL we'll be calling
USER_CACHE_URI = 'https://raw.githubusercontent.com/qrush/pickaxe.club/master/usercache.json'
USER_URI_TEMPLATE = 'https://raw.githubusercontent.com/qrush/pickaxe.club/master/world/stats/UUID.json'
BIOMES = [
  "Desert",
  "Taiga",
  "Mesa Plateau",
  "Ice Mountains",
  "Swampland M",
  "Birch Forest Hills",
  "Extreme Hills+ M",
  "Taiga M",
  "Jungle M",
  "MushroomIsland",
  "Savanna",
  "Roofed Forest M",
  "Mesa Plateau F",
  "Ice Plains Spikes",
  "Mega Taiga Hills",
  "FrozenRiver",
  "Ice Plains",
  "MushroomIslandShore",
  "ForestHills",
  "Forest",
  "Beach",
  "Roofed Forest",
  "Stone Beach",
  "Extreme Hills M",
  "Desert M",
  "JungleEdge",
  "Deep Ocean",
  "Extreme Hills",
  "Jungle",
  "Savanna Plateau",
  "DesertHills",
  "Birch Forest",
  "Mesa",
  "Mega Taiga",
  "Savanna M",
  "River",
  "Swampland",
  "Sunflower Plains",
  "Extreme Hills+",
  "Flower Forest",
  "Ocean",
  "TaigaHills",
  "Plains",
  "The End",
  "Hell",
  "Cold Taiga",
  "Birch Forest M",
  "JungleHills",
  "Savanna Plateau M",
  "Cold Beach",
  "Cold Taiga Hills"
]

request_uri = USER_CACHE_URI
url = "#{request_uri}"

# Actually fetch the contents of the remote URL as a String.
buffer = open(url).read

result = JSON.parse(buffer).sort_by{|hash| hash['name'].downcase}

# Loop through each of the elements in the 'result' Array & print some of their attributes.
#Haml::Engine.new(snippet.strip_heredoc).render
if mode == 'player_stats.csv'
  # CSV friendly version. Just printing to console and saving manually. Should just save to csv file instead.
    
  # leave in when doing the CSV version, match up the names to the stats. Comment out when doing the other versions.
  puts 'Name,Time Killed,Deaths,Players Killed,Villagers Killed,Pigmen Killed,Ghast Killed,Horses Killed,Seconds Played'


  result.each do |user|
    request_uri = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    url = "#{request_uri}"

    begin
      buffer = open(url).read
      result = JSON.parse(buffer)

      puts "#{user['name']},#{humanize(result['stat.playOneMinute'].to_i / 20)},#{result['stat.deaths'].to_i },#{result['stat.playerKills'].to_i},#{result['stat.killEntity.Villager'].to_i},#{result['stat.killEntity.PigZombie'].to_i},#{result['stat.killEntity.Ghast'].to_i},#{result['stat.killEntity.EntityHorse'].to_i},#{result['stat.playOneMinute'].to_i / 20}"
    rescue 
      #sometimes there is no matching json file.
      puts "#{user['name']},0,0,0,0,0,0,0,0"
    end

  end
end

if mode == 'adventuring_time'
    # BIOMES MISSING FOR ADVENTURING TIME ACHIEVEMENT
  result.each do |user|
    puts "Name: #{user['name']}"
    #puts "UUID: #{user['uuid']}"

    request_uri = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    url = "#{request_uri}"

    begin
      buffer = open(url).read
      result = JSON.parse(buffer)

      adventuring_time = result['achievement.exploreAllBiomes']['value'].to_s == "1"

      puts "Adventuring Time: #{adventuring_time ? "Yes" : "No"}"
      if !adventuring_time
        puts "Visited Biomes: #{result['achievement.exploreAllBiomes']['progress'].sort.join(", ")}"
        puts "Missing Biomes: #{(BIOMES - result['achievement.exploreAllBiomes']['progress']).sort.join(", ")}"
      end
    rescue 
      puts "No Stats File"
    end

    puts "\n"
  end
end

if mode == 'player_stats.html'
  require 'haml'
  # GENERATE STATS IN HTML
  rows = []

  #'Name,Time Killed,Deaths,Players Killed,Villagers Killed,Pigmen Killed,Ghast Killed,Horses Killed,Seconds Played'


  result.each do |user|
    request_uri = USER_URI_TEMPLATE.gsub("UUID", user['uuid'])
    url = "#{request_uri}"

    begin
      buffer = open(url).read
      result = JSON.parse(buffer)

       rows << ["#{user['name']}","#{humanize(result['stat.playOneMinute'].to_i / 20)}","#{result['stat.deaths'].to_i }","#{result['stat.playerKills'].to_i}","#{result['stat.killEntity.Villager'].to_i}","#{result['stat.killEntity.PigZombie'].to_i}","#{result['stat.killEntity.Ghast'].to_i}","#{result['stat.killEntity.EntityHorse'].to_i}","#{result['stat.playOneMinute'].to_i / 20}"]
    rescue 
      #sometimes there is no matching json file.
      rows << ["#{user['name']}","0","0","0","0","0","0","0","0"]
    end

  end

  puts generate_html(rows)

  
end



