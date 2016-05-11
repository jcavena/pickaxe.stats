
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

def kill_stats_table(rows)
  snippet = <<-EOF
    <h3 style="margin-top:0px;">Kill Stats</h3>
    <table id="stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
      <thead>
        <tr>
          <th>Avatar</th>
          <th>Name</th>
          <th>Time Played</th>
          <th>Deaths</th>
          <th>Avg TTL</th>
          <th>Players Killed</th>
    EOF
    KILLENTITY_KEYS.each do |key|
      snippet += "<th>#{key.split('.').last.gsub(/entity/i,'')}</th>"
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
        <td>#{row[2]}</td>
        <td data-sort='#{row[3]}'>#{humanize_time(row[3].to_i)}</td>
        <td>#{row[4]}</td>
    EOF
    5.upto(row.length - 1) do |index|
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
    snippet += <<-EOF
      <tr>
        <td data-sort="#{row[0].downcase}"><div class="head-skins" data-player="#{row[0]}"></div></td>
        <td>#{row[0]}</td>
        <td data-sort='#{row[1]}'>#{humanize_distance row[1].to_i}</td>
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
        <td data-sort="#{row[4]}" class="#{row[1] == 'Yes' ? 'success' : ''}">#{row[1]} - #{(row[4].to_f * 100).to_i}%</td>
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
    <table class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
      <thead>
        <tr>
          <th rowspan="2">Avatar</th>
          <th rowspan="2">Name</th>
          <th rowspan="2">Completed</th>
          <th>Completed</th>
        </tr>
        <tr>
          <th>Remaining</th>
        </tr>
      </thead>
      <tbody>
    EOF
  rows.each do |row|
    snippet += <<-EOF
      <tr>
        <td rowspan="2"><div class="scale-skins scale-3" data-player="#{row[0]}"></div></td>
        <td rowspan="2">#{row[0]}</td>
        <td rowspan="2" class="#{row[2] == '' ? 'success' : ''}">#{row[2] == '' ? 'Yes' : 'No'}</td>
        <td>#{row[1]}</td>
      </tr>
      <tr>
        <td>#{row[2]}</td>
      </tr>
    EOF
  end
  snippet += <<-EOF
      </tbody>
    </table>        
  EOF
end