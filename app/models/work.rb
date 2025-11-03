class Work < ApplicationRecord
  validates :title, presence: true
  validates :db_file_name, presence: true

  def db_file_path
    Rails.root.join('storage', 'uploads', db_file_name)
  end

  class << self
    def work_databases
      Work.all.map do |work|
        {
          id: work.id + SqliteDashboard.configuration.databases.count, 
          name: work.title, 
          path: work.db_file_path.to_s
        }
      end
    end

    def all_databases
      SqliteDashboard.configuration.databases + work_databases
    end
  end
end
