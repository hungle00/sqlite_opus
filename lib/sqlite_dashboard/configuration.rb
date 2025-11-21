module SqliteDashboard
  class Configuration
    attr_accessor :db_files, :allow_dml, :upload_directory

    def initialize
      @db_files = []
      @allow_dml = false
      @upload_directory = "storage/uploads"
      setup_defaults
    end

    def add_database(name, path)
      @db_files << { name: name, path: path }
    end

    def databases
      @db_files.map.with_index do |db, index|
        { id: index, name: db[:name] || File.basename(db[:path], ".*"), path: db[:path] }
      end
    end

    # Get full path for a file in upload directory
    def upload_file_path(filename)
      if defined?(Rails) && Rails.respond_to?(:root)
        Rails.root.join(@upload_directory, filename).to_s
      else
        File.join(@upload_directory, filename)
      end
    end

    private

    def setup_defaults
      # Default database configurations
      # Only set defaults if Rails is available
      if defined?(Rails) && Rails.respond_to?(:root)
        @db_files = [
          {
            name: "Development",
            path: Rails.root.join("storage", "development.sqlite3").to_s
          },
          {
            name: "Test",
            path: Rails.root.join("storage", "test.sqlite3").to_s
          }
        ]
      end

      # Default: read-only mode (DML operations disabled)
      @allow_dml = false
    end
  end
end

