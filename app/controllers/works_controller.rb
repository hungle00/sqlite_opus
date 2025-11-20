class WorksController < ApplicationController
  
  def new
    @work = Work.new
  end

  def create
    @work = Work.new(work_params)
    if @work.save
      redirect_to database_path(@work.id), notice: 'Opus was successfully created.'
    else
      redirect_to dashboard_path, notice: @work.errors.full_messages.join(', ')
    end
  end

  def upload_db
    db_file = params[:file]
    
    begin
      SqliteDashboard::Uploader.new(db_file).save
      render json: {
        output_file: db_file.original_filename
      }
    rescue ArgumentError => e
      render json: {
        error: e.message
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @work = Work.find(params[:id])
    if @work.destroy
      redirect_to dashboard_path, notice: 'Opus was successfully deleted.'
    else
      redirect_to dashboard_path, notice: 'Opus was failed to delete.'
    end
  end

  private

  def work_params
    params.require(:work).permit(:alias_name, :db_file_name)
  end
end
