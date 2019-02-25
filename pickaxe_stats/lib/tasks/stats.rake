require 'git'
require 'dotenv/load'
require 'logger'
require 'json'

require_relative '../constants.rb'
require_relative '../helpers.rb'

namespace :stats do
  desc "Import data from git repository history"
  task import: :environment do
    # Start
    start_time = Time.now
    puts "Execution of stats:import started at: #{start_time}"

    # Configure repository

    g_repo = Git.open("../../pickaxe.club")

    puts "\tUsing Git repository at: #{g_repo.repo}"

    counter = 0
    prev_date = nil
    index = 0
    sleep_duration = 2
    previous_weekly_stat_id = nil

    puts "\tPulling repository"
    g_repo.pull

    puts "\tGetting commit log..."
    commits = g_repo.log(300)

    puts "\tEnumerating the #{commits.count} commits in the log."

    commits.reverse_each do |commit|
      index +=1

      if commit.message =~ /final/
        # only process commits with a commit message with the word final in them
        counter +=1
        if prev_date
          days_since_last = ((commit.date - prev_date) / 60 / 60 / 24).to_i
        end

        puts "\t\t#{commits.count - index}\t#{counter+3}\t#{days_since_last}\t#{commit.sha}\t#{commit.message[0..20].ljust 23} \t#{commit.date}\t#{commit.author.name}"
        prev_date = commit.date

        check_for = "#{g_repo.repo}/index.lock"

        puts "\t\tChecking for #{check_for}"

        while File.exists?(check_for)
          puts "\t\t\tsleeping for #{sleep_duration} second(s)"
          sleep sleep_duration
        end

        puts "\t\tResetting repository to #{commit.sha}"
        g_repo.reset_hard commit

        week = counter + 3

        previous_weekly_stat_id = process_this_week(commit, week, previous_weekly_stat_id)

      end
    end

    # Completed
    end_time = Time.now
    duration = end_time - start_time

    puts "Execution of stats:import completed at: #{end_time}"
    puts "Duration: #{duration}"
  end

  # METHODS

  def process_this_week commit, week_number, previous_weekly_stat_id
    start_time = Time.now
    puts "\t\t\tprocess_this_week begin #{commit.date} #{week_number} - #{start_time}\n"

    player_list = get_player_list

    w = WeeklyStat.all.where(sha: commit.sha).first
    pw = WeeklyStat.find(previous_weekly_stat_id) unless previous_weekly_stat_id.nil?

    if w.nil?

      w = WeeklyStat.new
      w.commit_date = commit.date
      w.week_number = week_number
      w.sha = commit.sha
      w.message = commit.message
      w.player_count = player_list.count
      w.save


      print "\t\t\t\t"

      player_list.each do |player_data|
        p = Player.where(uuid: player_data['uuid']).first

        if p
          print "U"
          # puts "\t\t\t\tPlayer #{player_data['name']} exists, updating."
          p.last_seen_weekly_stat_id = w.id
          p.save
        else
          print "c"
          # puts "\t\t\t\tPlayer #{player_data['name']} does not exist, creating."
          p = Player.new
          p.name = player_data['name']
          p.uuid = player_data['uuid']
          p.first_seen_weekly_stat_id = w.id
          p.last_seen_weekly_stat_id = w.id
          p.save
        end

        process_player p, w, pw

      end
      print "\n"
    else
      puts "\t\t\tweekly stats record exists for this sha #{commit.sha}"
    end

    end_time = Time.now
    duration = end_time - start_time

    puts "\t\t\tprocess_this_week end #{commit.date} #{week_number} #{end_time}\n"
    puts "\t\t\tProcessing Time: #{duration}\n\n"
    puts "*" * 120

    return w.id
  end

  def get_player_list
    buffer = nil
    buffer = File.open(LOCAL_CURRENT_USER_CACHE_PATH).read

    JSON.parse(buffer).sort_by{|hash| hash['name'].downcase}
  end

  def get_player_data(player)
    buffer = []
    player_stat_file = LOCAL_CURRENT_USER_TEMPLATE_PATH.gsub("UUID", player.uuid)
    # puts "\t\t\t\t#{player_stat_file} for #{player.name}"
    if File.exists?(player_stat_file)
      buffer = File.open(player_stat_file).read
      output = JSON.parse(buffer)
    else
      output = []
    end

    return output
  end

  def process_player player, weekly_stat, previous_weekly_stat
    stats = get_player_data player

    # puts stats

    stats.each do |stat_data|
      s = Stat.new
      s.player = player
      s.weekly_stat_id = weekly_stat.id
      s.stat_key = stat_data[0]
      s.stat_value = stat_data[1]

      ps = previous_weekly_stat.stats.where(stat_key: s.stat_key, player_id: s.player_id).first

      if ps.nil? || ps.stat_value.blank?
        s.stat_delta = s.stat_value
      else
        # puts " s.stat_key is #{s.stat_key} / #{s.stat_value}"
        # puts "ps.stat_key is #{ps.stat_key} / #{ps.stat_value}"

        s.stat_delta = stat_data[1] - ps.stat_value
      end

      s.save
    end
  end
end
