module SqliteDashboard
  class Configuration
    attr_accessor :db_files, :allow_dml

    def initialize
      @db_files = []
      @allow_dml = false
    end

    def add_database(name, path)
      @db_files << { name: name, path: path }
    end

    def databases
      @db_files.map.with_index do |db, index|
        { id: index, name: db[:name] || File.basename(db[:path], ".*"), path: db[:path] }
      end
    end
  end
end
