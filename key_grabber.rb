

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
XCAVE_STATS = 'https://raw.githubusercontent.com/qrush/pickaxe.club/master/world/stats/a622e5a1-e4f2-4011-94dc-d0580de911e9.json'
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



  # GENERATE STATS IN HTML
  keys = []

  #look for achievement keys


  request_uri = XCAVE_STATS
  url = "#{request_uri}"

  begin
    buffer = open(url).read
    result = JSON.parse(buffer)

    keys << result.keys.sort

  rescue 
    #nothin'
  end

  puts keys.join(',')  

  



