class Work < ApplicationRecord
  validates :title, presence: true
  validates :db_file_name, presence: true

  after_destroy :delete_db_file

  def db_file_path
    Rails.root.join('storage', 'uploads', db_file_name)
  end

  class << self
    def work_databases
      Work.all.map do |work|
        {
          id: work.id,
          name: work.title, 
          path: work.db_file_path.to_s
        }
      end
    end

    def all_databases
      Work.count == 0 ? SqliteDashboard.configuration.databases : work_databases
    end
  end

  private

  def delete_db_file
    FileUtils.rm_f(db_file_path)
  end
end
