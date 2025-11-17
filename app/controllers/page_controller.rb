class PageController < ApplicationController
  def welcome
    @has_works = Work.count > 0
  end

  def create_first_database
    work = Work.create_first_database
    if work
      redirect_to sqlite_dashboard_path, notice: 'Sample database created successfully!'
    else
      redirect_to sqlite_dashboard_path, alert: 'You already have databases. Please upload a new one.'
    end
  end
end
