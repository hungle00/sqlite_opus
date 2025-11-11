# frozen_string_literal: true

# Metadata structures
TriggerMetadata = Struct.new(:name, :sql)
ViewMetadata = Struct.new(:name, :sql)
IndexMetadata = Struct.new(:name, :sql, :unique, :columns, :table)

class SqliteMetadata
  attr_reader :db_path

  def initialize(db_path)
  	@db_path = File.realpath(db_path)
  	@db = SQLite3::Database.new(@db_path)
  end

  def close
    @db&.close
  end

  def query(sql, params = [])
    @db.execute(sql, params)
  end

  def filename
    if @db_path.start_with?('file:')
      path = @db_path[5..-1]
    else
      path = @db_path
    end
    File.realpath(path.split('?').first)
  end

  def base_name
    File.basename(filename)
  end

  def created
    stat = File.stat(filename)
    Time.at(stat.ctime)
  end

  def modified
    stat = File.stat(filename)
    Time.at(stat.mtime)
  end

  def size_on_disk
    stat = File.stat(filename)
    stat.size
  end

  def tables
    query("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
      .flatten
  end

   def get_table_schema(table)
    return nil if table.nil? || table.empty?

    result = query("SELECT sql FROM sqlite_master WHERE tbl_name = ? AND type IN ('table', 'view')", [table])
    result.empty? ? nil : result.first.first
  end

  def get_indexes(table)
    # PRAGMA doesn't support parameterized queries, so we need to escape the table name
    escaped_table = escape_identifier(table)
    query("PRAGMA index_list(#{escaped_table})").map do |row|
      index_name = row[1]
      index_sql = get_index_sql(index_name)
      unique = row[2] == 1
      IndexMetadata.new(index_name, index_sql, unique, nil, table)
    end
  end

  def get_all_indexes
    query("SELECT name, sql FROM sqlite_master WHERE type = 'index' ORDER BY name")
      .map { |row| IndexMetadata.new(row[0], row[1], nil, nil, nil) }
  end

  def get_index_sql(index_name)
    result = query("SELECT sql FROM sqlite_master WHERE type='index' AND name=?", [index_name])
    result.empty? ? nil : result.first.first
  end

  # Column methods
  def get_columns(table)
    # PRAGMA doesn't support parameterized queries
    escaped_table = escape_identifier(table)
    query("PRAGMA table_info(#{escaped_table})").map do |row|
      {
        name: row[1],
        type: row[2],
        notnull: row[3] == 1,
        default_value: row[4],
        primary_key: row[5] == 1
      }
    end
  end

  # Foreign key methods
  def get_foreign_keys(table)
    # PRAGMA doesn't support parameterized queries
    escaped_table = escape_identifier(table)
    query("PRAGMA foreign_key_list(#{escaped_table})").map do |row|
      {
        id: row[0],
        seq: row[1],
        table: row[2],
        from: row[3],
        to: row[4],
        on_update: row[5],
        on_delete: row[6],
        match: row[7]
      }
    end
  end

  # View methods
  def get_view(name)
    result = query("SELECT name, sql FROM sqlite_master WHERE type = 'view' AND name = ?", [name])
    return nil if result.empty?
    ViewMetadata.new(result.first[0], result.first[1])
  end

  def get_all_views
    query("SELECT name, sql FROM sqlite_master WHERE type = 'view' ORDER BY name")
      .map { |row| ViewMetadata.new(row[0], row[1]) }
  end

  private

  # Helper method to escape table/column names for PRAGMA
  def escape_identifier(name)
    "\"#{name.to_s.gsub('"', '""')}\""
  end
end
