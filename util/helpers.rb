
def humanize_time secs
  #[[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
  [[60, ''], [60, ':'], [24, ':'], [1000, ' days ']].map{ |count, name|
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
  '%.2f km' % (cms.to_f*0.00001)
end

def humanize_number number
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def efficiency num1, num2, pretty = true
  return '-' if num1.to_i < MINIMUM_DAMAGE_DEALT
  result = '%.0f' % (num1.to_f / ((num1.to_i + num2.to_i).to_f) * 100)
  return result if pretty == false
  "#{result}%"
end

def build_chart_data keys, values, units = 'int'
  values_hash = Hash[*keys.zip(values).flatten]
  values_hash.select{|k,v| calculate_chart_value(v, units) > 0}.map{|k,v| {label: k.split('.').last.gsub(/onecm/i,'').split('_').map(&:capitalize).join(' '), value: calculate_chart_value(v, units)}}
end

def calculate_chart_value(value, units)
  case units
  when :km
    ('%.2f' % (value.to_f*0.00001)).to_f
  when :int
    value.to_i
  when :float
    value.to_f
  end
end

def build_graph_modal_button name, keys, values, units = :int
  return <<-EOF
    <button type="button" class="btn btn-info btn-xs" style="float:right;" data-toggle="modal" data-target="#graph_modal" data-name="#{name}" data-chart='#{build_chart_data(keys,values,units).to_json}'><i class="fa fa-pie-chart"></i></button>
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
          <th>Time Played</th>
          <th>Damage Dealt</th>
          <th>Damage Taken</th>
          <th>Damage Efficiency</th>
          <th>Deaths</th>
          <th>Avg TTL</th>
          <th>Players Killed</th>
    EOF
    KILLENTITY_KEYS.each do |key|
      snippet += "<th>#{key.split('.').last.gsub(/entity/i,'').split(/(?=[A-Z])/).map(&:capitalize).join(' ')}</th>"
      if KILLEDBY_KEYS.include? key.gsub('killEntity','entityKilledBy')
        snippet += "<th>Killed by #{key.split('.').last.gsub(/entity/i,'').split(/(?=[A-Z])/).map(&:capitalize).join(' ')}</th>"
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
        <td data-sort='#{row[1]}'>#{humanize_time(row[1].to_i)}</td>
        <td data-sort='#{row[2]}'>#{humanize_number(row[2])}</td>
        <td data-sort='#{row[3]}'>#{humanize_number(row[3])}</td>
        <td data-sort='#{efficiency row[2], row[3], false}'>#{efficiency row[2], row[3]}</td>
        <td>#{row[4]}</td>
        <td data-sort='#{row[5]}'>#{humanize_time(row[5].to_i)}</td>
        <td>#{row[6]}</td>
    EOF
    7.upto(row.length - 1) do |index|
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
    snippet += "<th>#{key.split('.').last.gsub(/onecm/i,'').capitalize}</th>"
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    graph_button = build_graph_modal_button row[0] + " #{humanize_distance row[1].to_i} Travel Distribution", TRAVEL_KEYS, row[2..-1], :km
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="head-skins" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort='#{row[1]}'>#{humanize_distance row[1].to_i} #{graph_button}</td>
    EOF
    2.upto(row.length - 1) do |index|
      snippet += "<td data-sort='#{row[index]}'>#{humanize_distance row[index]}</td>"
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
    snippet += "<th>#{key.split('.').last.split('_').map(&:capitalize).join(' ')}</th>"
  end
  snippet += <<-EOF
      </tr>
    </thead>
    <tbody>
  EOF
  rows.each do |row|
    graph_button = build_graph_modal_button row[0] + " #{humanize_number row[1].to_i} Food Items Distribution", FOOD_KEYS, row[2..-1], :int
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="head-skins" data-player="#{row[0]}"></div></td>
        <td>#{row[0]} </td>
        <td data-sort='#{row[1]}'>#{humanize_number row[1].to_i} #{graph_button}</td>
    EOF
    2.upto(row.length - 1) do |index|
      snippet += "<td data-sort='#{row[index]}'>#{humanize_number row[index]}</td>"
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
      snippet += "<th>#{key.split('.').last.split('_').map(&:capitalize).join(' ')}</th>"
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
        <td data-sort='#{row[1]}'>#{humanize_number row[1].to_i}</td>
    EOF
    2.upto(row.length - 1) do |index|
      snippet += "<td data-sort='#{row[index]}'>#{humanize_number row[index]}</td>"
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
    snippet += "<th>#{key.split('.').last.split('_').map(&:capitalize).join(' ')}</th>"
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
        <td data-sort='#{row[1]}'>#{humanize_number row[1].to_i}</td>
    EOF
    2.upto(row.length - 1) do |index|
      snippet += "<td data-sort='#{row[index]}'>#{humanize_number row[index]}</td>"
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
    snippet += "<th>#{key.split('.').last.split(/(?=[A-Z])/).map(&:capitalize).join(' ')}</th>"
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
        <td data-sort='#{row[1]}'>#{humanize_time(row[1].to_i)}</td>     
    EOF
    2.upto(row.length - 1) do |index|
      if row[index] =~ /t/ 
        snippet += "<td data-sort='#{row[index].gsub('t','')}'>#{humanize_time row[index].gsub('t','').to_i}</td>"
      else
        snippet += "<td data-sort='#{row[index]}'>#{humanize_number row[index]}</td>"
      end
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
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="scale-skins scale-3" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort="#{row[4]}" class="#{row[1] == 'Yes' ? 'success' : ''}">#{(row[4].to_f * 100).to_i}%</td>
        <td data-sort="#{row[4]}" style="padding:4;vertical-align:middle;">
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
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="scale-skins scale-3" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort="#{row[3]}" class="#{row[2] == '' ? 'success' : ''}">#{(row[3].to_f * 100).to_i}%</td>
        <td data-sort="#{row[3]}" style="padding:4;vertical-align:middle;">
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