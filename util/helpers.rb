
def humanize_time secs
  secs = clean_stat(secs).to_i
  #[[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
  [[60, ''], [60, ':'], [24, ':'], [1000, ' d ']].map{ |count, name|
    if secs > 0
      secs, n = secs.divmod(count)
      if n.to_i < 10 && name != ' days '
        "0#{n.to_i}#{name}"
      else
        "#{n.to_i}#{name}"
      end
    end
  }.compact.reverse.join('')
end

def humanize_distance cms
  '%.2f km' % (clean_stat(cms).to_f*0.00001)
end

def humanize_number number
  clean_stat(number).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def efficiency num1, num2 #, pretty = true
  return '-' if clean_stat(num1).to_i < MINIMUM_DAMAGE_DEALT
  '%.0f%' % (clean_stat(num1).to_f / ((clean_stat(num1).to_i + clean_stat(num2).to_i).to_f) * 100)
end

def build_chart_data keys, values, units = 'int'
  keys = keys.map{|s| s.sub(/\A(?!current\.)/, "current.")}
  if units.to_s == 'bool'
    true_values = keys.split(',').map(&:strip)
    false_values = values.split(',').map(&:strip)
    values_hash = {}
    if true_values.any?
      values_hash = Hash[*true_values.zip([{'value' => 1, 'color' => '#65A620'}]*true_values.size).flatten]
    end
    if false_values.any?
      values_hash.merge!(Hash[*false_values.zip([{'value' => 1, 'color' => '#961A1A'}]*false_values.size).flatten])
    end
    values_hash.map{|k,v| {label: pretty_label(k), value: v['value'].to_i, color: v['color'].to_s}}.to_json
  else
    values_hash = Hash[*keys.zip(values.values_at(*keys)).flatten]
    values_hash.select{|k,v| calculate_chart_value(v, units) > 0}.map{|k,v| {label: pretty_label(k), value: calculate_chart_value(v, units)}}.to_json
  end
end

def calculate_chart_value(value, units)
  case units
  when :km
    ('%.2f' % (clean_stat(value).to_f*0.00001)).to_f
  when :int
    clean_stat(value).to_i
  when :float
    clean_stat(value).to_f
  end
end

def calculate_delta(row, stat, formatter = nil)
  previous_stat = clean_stat(row['previous.' + stat]).to_i
  current_stat = clean_stat(row['current.' + stat]).to_i

  delta = current_stat - previous_stat

  unless formatter.nil?
    pretty_delta = delta
    pretty_delta = "#{pretty_delta}t" if row['current.' + stat] =~ /t/ 
    pretty_delta = send(formatter, pretty_delta)
  end

  if delta > 0
    "<span style=\"color:#439A45;white-space:nowrap\"><i class=\"fa fa-caret-up\"></i> #{pretty_delta}</span>"
  elsif delta < 0
    "<span style=\"color:#d9534f;white-space:nowrap\"><i class=\"fa fa-caret-down\"></i> #{pretty_delta}</span>"
  else
    ""
  end
end

def pretty_label label
  label.split('.').last.gsub(/onecm|entity|eaten/i,'').split('_').map{|l| l.split(/(?=[A-Z])/)}.flatten.map(&:capitalize).join(' ')
end

def pretty_distance dist
  humanize_distance dist
end

def pretty_stat stat
  if stat =~ /t/ 
    humanize_time stat
  else
    humanize_number stat
  end
end

def clean_stat stat
  stat.to_s.gsub(/\D/, '')
end

def build_graph_modal_button name, keys, values, units = :int
  return <<-EOF
    <button type="button" class="btn btn-info btn-xs" style="float:right;" data-toggle="modal" data-target="#graph_modal" data-name="#{name}" data-chart='#{build_chart_data(keys,values,units)}' data-chart-type='#{units.to_s == 'bool' ? 'donut' : 'pie'}'><i class="fa fa-pie-chart"></i></button>
  EOF
end

def kill_stats_table(rows)
  snippet = <<-EOF
    <h3 style="margin-top:0px;">Kill Stats</h3>
    <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
      <thead>
        <tr>
          <th>Avatar</th>
          <th>Name</th>
          <th>Damage Dealt</th>
          <th>Damage Taken</th>
          <th>Damage Efficiency</th>
          <th>Deaths</th>
          <th>Avg TTL</th>
          <th>Players Killed</th>
    EOF
    KILLENTITY_KEYS.each do |key|
      snippet += "<th>#{pretty_label key}</th>"
      if KILLEDBY_KEYS.include? key.gsub('killEntity','entityKilledBy')
        snippet += "<th>Killed by #{pretty_label key}</th>"
      end
    end
    snippet += <<-EOF
        </tr>
      </thead>
      <tbody>
    EOF
  rows.each do |row|
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="head-skins" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort='#{clean_stat row[1]}'>#{pretty_stat row[1]}</td>
        <td data-sort='#{clean_stat row[2]}'>#{pretty_stat row[2]}</td>
        <td data-sort='#{clean_stat(efficiency row[1], row[2])}'>#{efficiency row[1], row[2]}</td>
        <td>#{row[3]}</td>
        <td data-sort='#{clean_stat row[4]}'>#{pretty_stat row[4]}</td>
        <td>#{row[5]}</td>
    EOF
    6.upto(row.length - 1) do |index|
      snippet += "<td>#{row[index]}</td>"
    end
    snippet += <<-EOF        
      </tr>
    EOF
  end

  snippet += <<-EOF
      </tbody>
    </table>
  EOF
end

def travel_stats_table(rows)
  snippet = <<-EOF
  <h3 style="margin-top:0px;">Travel Stats</h3>
  <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
    <thead>
      <tr>
        <th>Avatar</th>
        <th>Name</th>
        <th>Total Distance</th>
  EOF
  TRAVEL_KEYS.each do |key|
    snippet += "<th>#{pretty_label key}</th>"
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    graph_button = build_graph_modal_button row['name'] + " #{pretty_distance row['current.travel_total']} Travel Distribution", TRAVEL_KEYS, row, :km
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row['name'].downcase}"><div class="head-skins" data-player="#{row['name']}"></div></td>
        <td>#{row['name']}</td>
        <td data-sort='#{clean_stat row['current.travel_total']}'>#{pretty_distance row['current.travel_total']} #{graph_button}<br>#{calculate_delta(row, 'travel_total', 'pretty_distance')}</td>
    EOF
    TRAVEL_KEYS.each do |key|
      snippet += "<td data-sort='#{clean_stat row['current.' + key]}'>#{pretty_distance row['current.' + key]}<br>#{calculate_delta(row, key, 'pretty_distance')}</td>"
    end
    snippet += <<-EOF        
      </tr>
    EOF
  end

  snippet += <<-EOF
      </tbody>
    </table>
  EOF
end

def food_stats_table(rows)
  snippet = <<-EOF
  <h3 style="margin-top:0px;">Food Stats</h3>
  <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
    <thead>
      <tr>
        <th>Avatar</th>
        <th>Name</th>
        <th style="white-space:nowrap;">Total Food</th>
  EOF
  FOOD_KEYS.each do |key|
    snippet += "<th>#{pretty_label key}</th>"
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    graph_button = build_graph_modal_button row['name'] + " #{pretty_stat row['current.food_total']} Food Items Distribution", FOOD_KEYS, row, :int
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row['name'].downcase}"><div class="head-skins" data-player="#{row['name']}"></div></td>
        <td>#{row['name']} </td>
        <td data-sort='#{clean_stat row['current.food_total']}'>#{pretty_stat row['current.food_total']} #{graph_button}<br>#{calculate_delta(row, 'food_total', 'pretty_stat')}</td>
    EOF
    FOOD_KEYS.each do |key|
      snippet += "<td data-sort='#{clean_stat row['current.' + key]}'>#{pretty_stat row['current.' + key]}<br>#{calculate_delta(row, key, 'pretty_stat')}</td>"
    end
    
    snippet += <<-EOF
      </tr>
    EOF
  end
  snippet += <<-EOF
      </tbody>
    </table>
  EOF
end

def crafted_stats_table(rows)
  snippet = <<-EOF
  <h3 style="margin-top:0px;">Crafting Stats</h3>
  <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
    <thead>
      <tr>
        <th>Avatar</th>
        <th>Name</th>
        <th>Total Crafted</th>
  EOF
  CRAFTING_KEYS.each do |key|
    if key == 'stat.craftingTableInteraction'
      snippet += "<th>Crafting Table Interaction</th>"
    else  
      snippet += "<th>#{pretty_label key}</th>"
    end
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    #graph_button = build_graph_modal_button row['name'] + " #{pretty_stat row['current.crafted_total']} Crafting Distribution", CRAFTING_KEYS, row, :int
    graph_button = ""
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row['name'].downcase}"><div class="head-skins" data-player="#{row['name']}"></div></td>
        <td>#{row['name']}</td>
        <td data-sort='#{clean_stat row['current.crafted_total']}'>#{pretty_stat row['current.crafted_total']} #{graph_button}<br>#{calculate_delta(row, 'crafted_total', 'pretty_stat')}</td>
    EOF
    CRAFTING_KEYS.each do |key|
      snippet += "<td data-sort='#{clean_stat row['current.' + key]}'>#{pretty_stat row['current.' + key]}<br>#{calculate_delta(row, key, 'pretty_stat')}</td>"
    end
    snippet += <<-EOF        
      </tr>
    EOF
  end

  snippet += <<-EOF
      </tbody>
    </table>
  EOF
end

def mined_stats_table(rows)
  snippet = <<-EOF
  <h3 style="margin-top:0px;">Mining Stats</h3>
  <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
    <thead>
      <tr>
        <th>Avatar</th>
        <th>Name</th>
        <th>Total Mined</th>
  EOF
  MINING_KEYS.each do |key|
    snippet += "<th>#{pretty_label key}</th>"
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="head-skins" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort='#{clean_stat row[1]}'>#{pretty_stat row[1].to_i}</td>
    EOF
    2.upto(row.length - 1) do |index|
      snippet += "<td data-sort='#{clean_stat row[index]}'>#{pretty_stat row[index]}</td>"
    end
    snippet += <<-EOF        
      </tr>
    EOF
  end

  snippet += <<-EOF
      </tbody>
    </table>
  EOF
  
end

def general_stats_table(rows)
  snippet = <<-EOF
  <h3 style="margin-top:0px;">General Stats</h3>
  <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
    <thead>
      <tr>
        <th>Avatar</th>
        <th>Name</th>
        <th>Time Played</th>
  EOF
  GENERAL_STATS_KEYS[1..-1].each do |key|
    snippet += "<th>#{pretty_label key}</th>"
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row['name'].downcase}"><div class="head-skins" data-player="#{row['name']}"></div></td>
        <td>#{row['name']}</td>   
        <td data-sort='#{clean_stat row['current.stat.playOneMinute']}'>#{humanize_time(row['current.stat.playOneMinute'].to_i)}<br>#{calculate_delta(row,'stat.playOneMinute', 'humanize_time')}</td>     
    EOF

    GENERAL_STATS_KEYS[1..-1].each do |key|
      snippet += "<td data-sort='#{clean_stat row['current.' + key]}'>#{pretty_stat row['current.' + key]}<br>#{calculate_delta(row, key, 'pretty_stat')}</td>"  
    end
    snippet += <<-EOF        
      </tr>
    EOF
  end

  snippet += <<-EOF
      </tbody>
    </table>
  EOF
  
end

def adventuring_time_table(rows)
  snippet = <<-EOF
    <h3 style="margin-top:0px;">Adventuring Time</h3>
    <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
      <thead>
        <tr>
          <th>Avatar</th>
          <th>Name</th>
          <th>Completed</th>
          <th>Visited / <span class="danger">Remaining</span></th>
        </tr>
      </thead>
      <tbody>
    EOF
  rows.each do |row|
    graph_button = build_graph_modal_button row[0] + " #{pretty_stat row[1]} Adventuring Time Biomes", row[5], row[3], :bool
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="scale-skins scale-3" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort="#{(row[4]*100).to_i}" class="#{row[1] == 'Yes' ? 'success' : ''}">#{(row[4].to_f * 100).to_i}% #{graph_button}</td>
        <td data-sort="#{(row[4]*100).to_i}" style="padding:4;vertical-align:middle;">
    EOF
    if row[2] != ''
      snippet += <<-EOF
        <p class="bg-success" style="padding:10px;">#{row[2]}</p>
      EOF
    end
    if row[3] != ''
      snippet += <<-EOF
        <p class="bg-danger" style="padding:10px;margin-bottom:0;">#{row[3]}</p></span></td>
      EOF
    end
    snippet += "</tr>"
  end
  snippet += <<-EOF
      </tbody>
    </table>        
  EOF
end

def achievements_table(rows)
  snippet = <<-EOF
    <h3 style="margin-top:0px;">Achievements</h3>
    <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
      <thead>
        <tr>
          <th>Avatar</th>
          <th>Name</th>
          <th>Completed</th>
          <th>Completed / Remaining</th>
        </tr>
      </thead>
      <tbody>
    EOF
  rows.each do |row|
    graph_button = build_graph_modal_button row[0] + " #{pretty_stat row[1]} Achievements", row[4], row[2], :bool
    
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="scale-skins scale-3" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort="#{(row[3].to_f*100).to_i}" class="#{row[2] == '' ? 'success' : ''}">#{(row[3].to_f * 100).to_i}% #{graph_button}</td>
        <td data-sort="#{(row[3].to_f*100).to_i}" style="padding:4;vertical-align:middle;">
    EOF
    if row[1] != ''
      snippet += <<-EOF
        <p class="bg-success" style="padding:10px;">#{row[1]}</p>
      EOF
    end
    if row[2] != ''
      snippet += <<-EOF
        <p class="bg-danger" style="padding:10px;margin-bottom:0;">#{row[2]}</p></span></td>
      EOF
    end
    snippet += "</tr>"
  end
  snippet += <<-EOF
      </tbody>
    </table>        
  EOF
end