class Work < ApplicationRecord
  validates :db_file_name, presence: true
  validate :must_be_sqlite_database

  after_destroy :delete_db_file

  def db_file_path
    Rails.root.join('storage', 'uploads', db_file_name)
  end

  def db_name
    alias_name.presence || db_file_name.split('.').first
  end

  class << self
    def work_databases
      Work.all.map do |work|
        {
          id: work.id,
          name: work.db_name, 
          path: work.db_file_path.to_s
        }
      end
    end

    def all_databases
      Work.count == 0 ? SqliteDashboard.configuration.databases : work_databases
    end

    def create_first_database
      if Work.count == 0
        Work.create(db_file_name: 'chinook.db', alias_name: 'Chinook')
      end
    end
  end

  private

  def delete_db_file
    FileUtils.rm_f(db_file_path)
  end

  def must_be_sqlite_database
    unless db_file_name.end_with?('.sqlite3') || db_file_name.end_with?('.db')
      errors.add(:db_file_name, "must be a SQLite database file or a SQLite database file")
    end
  end
end
