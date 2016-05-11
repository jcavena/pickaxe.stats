
def humanize secs
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


def generate_html(rows)
  #html_header + html_body(rows)
  html_table(rows)
end


def html_header
  snippet = <<-EOF
<!doctype html>
  <html>
    <head>
      <title>Pickaxe.club Killer Stats!</title>
      <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css">
      <style>
        body{
          font-family: arial,sans-serif;
          font-size: .8em;
        }
        
      </style>
      <script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.3/jquery.min.js"></script>
      <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>
      <script type="text/javascript" language="javascript" src="skinpreview.js"></script>
    </head>
  EOF
end

def html_body(rows)
  snippet = <<-EOF
    <body>
      #{html_table(rows)}
    </body>
    <script>
      $(document).ready(function(){
        $(".head-skins").skinPreview({
          scale: 4, 
          head: true
        });
        
        $('#killer_stats').DataTable();
        
      });
    </script>
  </html>
  EOF
end

def html_table(rows)
  snippet = <<-EOF
    <table id="killer_stats" class="table table-striped table-bordered" cellspacing="0" width="100%" data-page-length='100'>
      <thead>
        <tr>
          <th>Avatar</th>
          <th>Name</th>
          <th>Time Played</th>
          <th>Deaths</th>
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
        <td data-sort='#{row[1]}'>#{humanize(row[1].to_i)}</td>
        <td>#{row[2]}</td>
        <td>#{row[3]}</td>
    EOF
    4.upto(row.length - 1) do |index|
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

