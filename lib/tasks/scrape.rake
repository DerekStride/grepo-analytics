require 'net/http'

GREPOLIS_ENDPOINTS = {
  players: 'https://en94.grepolis.com/data/players.txt.gz',
  alliances: 'https://en94.grepolis.com/data/alliances.txt.gz',
  towns: 'https://en94.grepolis.com/data/towns.txt.gz',
  islands: 'https://en94.grepolis.com/data/islands.txt.gz',
  player_kills_all: 'https://en94.grepolis.com/data/player_kills_all.txt.gz',
  player_kills_att: 'https://en94.grepolis.com/data/player_kills_att.txt.gz',
  player_kills_def: 'https://en94.grepolis.com/data/player_kills_def.txt.gz',
  alliance_kills_all: 'https://en94.grepolis.com/data/alliance_kills_all.txt.gz',
  alliance_kills_att: 'https://en94.grepolis.com/data/alliance_kills_att.txt.gz',
  alliance_kills_def: 'https://en94.grepolis.com/data/alliance_kills_def.txt.gz',
  conquers: 'https://en94.grepolis.com/data/conquers.txt.gz'
}

namespace :scrape do
  task :all do
    timestamp = Time.now.utc.to_i
    Rake::Task["scrape:alliances"].invoke(timestamp)
    Rake::Task["scrape:players"].invoke(timestamp)
    Rake::Task["scrape:towns"].invoke(timestamp)
    Rake::Task["scrape:player_kills_all"].invoke(timestamp)
    Rake::Task["scrape:player_kills_att"].invoke(timestamp)
    Rake::Task["scrape:player_kills_def"].invoke(timestamp)
    Rake::Task["scrape:alliance_kills_all"].invoke(timestamp)
    Rake::Task["scrape:alliance_kills_att"].invoke(timestamp)
    Rake::Task["scrape:alliance_kills_def"].invoke(timestamp)
    Rake::Task["scrape:conquers"].invoke(timestamp)
  end

  task :players, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:players)
    players = db[:players]
    rows.each_line do |row|
      id, name, alliance_id, points, rank, towns = normalize_row(row)
      players.insert(
        id: id, timestamp: timestamp, name: name, alliance_id: alliance_id, points: points, rank: rank, towns: towns
      )
    end
  end

  task :alliances, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:alliances)
    alliances = db[:alliances]
    rows.each_line do |row|
      id, name, points, towns, members, rank = normalize_row(row)
      alliances.insert(
        id: id, timestamp: timestamp, name: name, points: points, towns: towns, members: members, rank: rank
      )
    end
  end

  task :towns, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:towns)
    towns = db[:towns]
    rows.each_line do |row|
      id, player_id, name, island_x, island_y, number_on_island, points = normalize_row(row)
      towns.insert(
        id: id, timestamp: timestamp, player_id: player_id, name: name, island_x: island_x,
        island_y: island_y, number_on_island: number_on_island, points: points
      )
    end
  end

  task :islands do
    rows = fetch_data(:islands)
    islands = db[:islands]
    rows.each_line do |row|
      id, x, y, island_type, available_towns = normalize_row(row)
      islands.insert(
        id: id, x: x, y: y, island_type: island_type, available_towns: available_towns
      )
    end
  end

  task :player_kills_all, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:player_kills_all)
    player_kills_all = db[:player_kills_all]
    rows.each_line do |row|
      rank, player_id, points = normalize_row(row)
      player_kills_all.insert(rank: rank, timestamp: timestamp, player_id: player_id, points: points)
    end
  end

  task :player_kills_att, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:player_kills_att)
    player_kills_att = db[:player_kills_att]
    rows.each_line do |row|
      rank, player_id, points = normalize_row(row)
      player_kills_att.insert(rank: rank, timestamp: timestamp, player_id: player_id, points: points)
    end
  end

  task :player_kills_def, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:player_kills_def)
    player_kills_def = db[:player_kills_def]
    rows.each_line do |row|
      rank, player_id, points = normalize_row(row)
      player_kills_def.insert( rank: rank, timestamp: timestamp, player_id: player_id, points: points )
    end
  end

  task :alliance_kills_all, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:alliance_kills_all)
    alliance_kills_all = db[:alliance_kills_all]
    rows.each_line do |row|
      rank, alliance_id, points = normalize_row(row)
      alliance_kills_all.insert(rank: rank, timestamp: timestamp, alliance_id: alliance_id, points: points)
    end
  end

  task :alliance_kills_att, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:alliance_kills_att)
    alliance_kills_att = db[:alliance_kills_att]
    rows.each_line do |row|
      rank, alliance_id, points = normalize_row(row)
      alliance_kills_att.insert(rank: rank, timestamp: timestamp, alliance_id: alliance_id, points: points)
    end
  end

  task :alliance_kills_def, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:alliance_kills_def)
    alliance_kills_def = db[:alliance_kills_def]
    rows.each_line do |row|
      rank, alliance_id, points = normalize_row(row)
      alliance_kills_def.insert(rank: rank, timestamp: timestamp, alliance_id: alliance_id, points: points)
    end
  end

  task :conquers, [:timestamp] do |t, args|
    timestamp = args[:timestamp]
    rows = fetch_data(:conquers)
    conquers = db[:conquers]
    rows.each_line do |row|
      town_id, conquered_at, new_player_id, old_player_id, new_ally_id, old_ally_id, town_points = normalize_row(row)
      insert_if_nil(new_player_id, :players, timestamp)
      insert_if_nil(old_player_id, :players, timestamp)
      insert_if_nil(new_ally_id, :alliances, timestamp)
      insert_if_nil(old_ally_id, :alliances, timestamp)
      conquers.insert(
        town_id: town_id, timestamp: timestamp, conquered_at: conquered_at, new_player_id: new_player_id,
          old_player_id: old_player_id, new_ally_id: new_ally_id, old_ally_id: old_ally_id,
          town_points: town_points
      )
    end
  end
end

def fetch_data(table_name)
  uri = URI(GREPOLIS_ENDPOINTS[table_name])
  resp = Net::HTTP.get_response(uri)
  gz = Zlib::GzipReader.new(StringIO.open(resp.body))
  gz.read
ensure
  gz.close
end

def normalize_row(row)
  row.chomp.split(',').map { |r| r.empty? ? nil : r }
end

def insert_if_nil(id, table_name, timestamp)
  table = db[table_name]
  return if table.where(id: id, timestamp: timestamp).any? || id.nil?
  table.insert(id: id, timestamp: timestamp)
end

def db
  @db ||= Sequel.connect(ENV['DATABASE_URL'])
end
