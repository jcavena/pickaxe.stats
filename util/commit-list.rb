require 'git'

g = Git.open("../pickaxe.club")

puts g.repo

counter = 0
prev_date = nil

g.log(300).each_with_index do |commit, index|

  if commit.message =~ /final/
    counter += 1
    if prev_date
      days_since_last = ((prev_date - commit.date) / 60 / 60 / 24).to_i
    end
    puts "#{g.log(300).count - index}\t#{218-counter}\t#{days_since_last}\t#{commit.sha} \t#{commit.message[0..20].ljust 23} \t#{commit.date}\t#{commit.author.name} "
    prev_date = commit.date
  end
end


