class WorksController < ApplicationController
  
  def new
    @work = Work.new
  end

  def create
    @work = Work.new(work_params)
    if @work.save
      redirect_to database_path(@work.id), notice: 'Opus was successfully created.'
    else
      redirect_to sqlite_dashboard_path, notice: 'Opus was failed to create.'
    end
  end

  def upload_ly
    lily_file = params[:file]
    
    Lilypond::Uploader.new(lily_file).save

    render json: {
      output_file: lily_file.original_filename
    }
  end

  private

  def work_params
    params.require(:work).permit(:title, :db_file_name)
  end
end
