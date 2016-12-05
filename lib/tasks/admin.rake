require 'sequel'
require 'pry-byebug'

namespace :admin do
  task :setup do
    Rake::Task['admin:create_players'].invoke
    Rake::Task['admin:create_alliances'].invoke
    Rake::Task['admin:create_towns'].invoke
    Rake::Task['admin:create_player_kills_all'].invoke
    Rake::Task['admin:create_player_kills_att'].invoke
    Rake::Task['admin:create_player_kills_def'].invoke
    Rake::Task['admin:create_alliance_kills_all'].invoke
    Rake::Task['admin:create_alliance_kills_att'].invoke
    Rake::Task['admin:create_alliance_kills_def'].invoke
    Rake::Task['admin:create_conquers'].invoke
    Rake::Task['admin:create_islands'].invoke
  end

  task :reset do
    db.drop_table(
      :players, :alliances, :towns, :player_kills_all, :player_kills_att, :player_kills_def,
        :alliance_kills_all, :alliance_kills_att, :alliance_kills_def, :conquers
    )
  end

  task create_players: :create_alliances do
    db.create_table?(:players) do
      Integer :id
      Integer :timestamp
      String :name
      Integer :points
      Integer :rank
      Integer :towns
      Integer :alliance_id
      foreign_key [:alliance_id, :timestamp], :alliances
      primary_key [:id, :timestamp]
    end
  end

  task :create_alliances do
    db.create_table?(:alliances) do
      Integer :id
      Integer :timestamp
      String :name
      Integer :points
      Integer :towns
      Integer :members
      Integer :rank
      primary_key [:id, :timestamp]
    end
  end

  task create_towns: %i(create_players create_islands) do
    db.create_table?(:towns) do
      Integer :id
      Integer :timestamp
      String :name
      Integer :island_x
      Integer :island_y
      Integer :number_on_island
      Integer :points
      Integer :player_id
      foreign_key [:player_id, :timestamp], :players
      foreign_key [:island_x, :island_y], :islands
      primary_key [:id, :timestamp]
    end
  end

  task create_player_kills_all: :create_players do
    db.create_table?(:player_kills_all) do
      Integer :rank
      Integer :timestamp
      Integer :points
      Integer :player_id
      foreign_key [:player_id, :timestamp], :players
      primary_key [:rank, :player_id, :timestamp]
    end
  end

  task create_player_kills_att: :create_players do
    db.create_table?(:player_kills_att) do
      Integer :rank
      Integer :timestamp
      Integer :points
      Integer :player_id
      foreign_key [:player_id, :timestamp], :players
      primary_key [:rank, :player_id, :timestamp]
    end
  end

  task create_player_kills_def: :create_players do
    db.create_table?(:player_kills_def) do
      Integer :rank
      Integer :timestamp
      Integer :points
      Integer :player_id
      foreign_key [:player_id, :timestamp], :players
      primary_key [:rank, :player_id, :timestamp]
    end
  end

  task create_alliance_kills_all: :create_alliances do
    db.create_table?(:alliance_kills_all) do
      Integer :rank
      Integer :timestamp
      Integer :points
      Integer :alliance_id
      foreign_key [:alliance_id, :timestamp], :alliances
      primary_key [:rank, :alliance_id, :timestamp]
    end
  end

  task create_alliance_kills_att: :create_alliances do
    db.create_table?(:alliance_kills_att) do
      Integer :rank
      Integer :timestamp
      Integer :points
      Integer :alliance_id
      foreign_key [:alliance_id, :timestamp], :alliances
      primary_key [:rank, :alliance_id, :timestamp]
    end
  end

  task create_alliance_kills_def: :create_alliances do
    db.create_table?(:alliance_kills_def) do
      Integer :rank
      Integer :timestamp
      Integer :points
      Integer :alliance_id
      foreign_key [:alliance_id, :timestamp], :alliances
      primary_key [:rank, :alliance_id, :timestamp]
    end
  end

  task create_conquers: %i(create_players create_alliances create_towns) do
    db.create_table?(:conquers) do
      Integer :timestamp
      Integer :conquered_at
      Integer :town_points
      Integer :new_player_id
      Integer :old_player_id
      Integer :new_ally_id
      Integer :old_ally_id
      Integer :town_id
      foreign_key [:new_player_id, :timestamp], :players
      foreign_key [:old_player_id, :timestamp], :players
      foreign_key [:new_ally_id, :timestamp], :alliances
      foreign_key [:old_ally_id, :timestamp], :alliances
      foreign_key [:town_id, :timestamp], :towns
      primary_key [:town_id, :conquered_at, :timestamp]
    end
  end

  task :create_islands do
    db.create_table?(:islands) do
      Integer :id
      Integer :x
      Integer :y
      Integer :island_type
      Integer :available_towns
      String :abundant_resource
      String :scarce_resource
      primary_key [:x, :y]
    end
  end
end

def db
  @db ||= Sequel.connect(ENV['DATABASE_URL'])
end
