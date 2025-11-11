# frozen_string_literal: true

module SqliteDashboard
  class SavedQueriesController < ApplicationController
    layout "sqlite_dashboard/application"

    before_action :set_saved_query, only: [:show, :destroy]

    def index
      @saved_queries = SavedQuery.recent
      database_name = params[:database_name]
      @saved_queries = @saved_queries.for_database(database_name) if database_name.present?

      respond_to do |format|
        format.json { render json: @saved_queries }
        format.html { @saved_queries }
      end
    end

    def show
      respond_to do |format|
        format.json { render json: @saved_query }
        format.html { @saved_query }
      end
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: { error: "Saved query not found" }, status: :not_found }
        format.html { redirect_to sqlite_dashboard_saved_queries_path, alert: "Saved query not found" }
      end
    end

    def create
      @saved_query = SavedQuery.new(saved_query_params)

      if @saved_query.save
        respond_to do |format|
          format.json { render json: @saved_query, status: :created }
          format.html { redirect_to sqlite_dashboard_saved_queries_path, notice: "Query saved successfully" }
        end
      else
        respond_to do |format|
          format.json { render json: { error: @saved_query.errors.full_messages.join(", ") }, status: :unprocessable_entity }
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      if @saved_query.destroy
        respond_to do |format|
          format.json { render json: { message: "Query deleted successfully" } }
          format.html { redirect_to sqlite_dashboard_saved_queries_path, notice: "Query deleted successfully" }
        end
      else
        respond_to do |format|
          format.json { render json: { error: "Failed to delete query" }, status: :unprocessable_entity }
          format.html { redirect_to sqlite_dashboard_saved_queries_path, alert: "Failed to delete query" }
        end
      end
    end

    private

    def set_saved_query
      @saved_query = SavedQuery.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: { error: "Saved query not found" }, status: :not_found }
        format.html { redirect_to sqlite_dashboard_saved_queries_path, alert: "Saved query not found" }
      end
    end

    def saved_query_params
      params.require(:saved_query).permit(:name, :query, :database_name, :description)
    end
  end
end

