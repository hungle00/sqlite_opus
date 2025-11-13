require 'sqlite3'
require 'csv'
require 'json'
require Rails.root.join('lib', 'sqlite_metadata')

module SqliteDashboard
  class DatabasesController < ApplicationController
    layout "sqlite_dashboard/application"
 
    before_action :set_database, only: [:show, :execute_query, :export_csv, :export_json, :tables, :table_info]
    before_action :set_metadata, only: [:show, :tables, :table_info]

    def index
      @databases = Work.all_databases
      @saved_queries = SavedQuery.recent.limit(10)

      @work = Work.new
    end

    def show
      @tables = @metadata.tables
      @work = Work.find_by(id: @database[:id])
    end

    def worksheet
      @databases = Work.all_databases
      @saved_queries = SavedQuery.recent.limit(20)
    end

    def execute_query
      @query = params[:query]

      Rails.logger.debug "=" * 80
      Rails.logger.debug "Execute Query Called"
      Rails.logger.debug "Request format: #{request.format}"
      Rails.logger.debug "Accept header: #{request.headers['Accept']}"
      Rails.logger.debug "Query: #{@query}"
      Rails.logger.debug "=" * 80

      begin
        @results = execute_sql(@query)
        Rails.logger.debug "Query executed successfully. Results: #{@results.inspect}"

        respond_to do |format|
          format.json do
            Rails.logger.debug "Rendering JSON response"
            render json: @results
          end
          format.turbo_stream do
            Rails.logger.debug "Rendering turbo_stream response"
            render :execute_query
          end
          format.html do
            Rails.logger.debug "Falling back to HTML redirect"
            redirect_to sqlite_dashboard_database_path(@database[:id])
          end
        end
      rescue => e
        @error = e.message
        Rails.logger.error "Query execution error: #{@error}"

        respond_to do |format|
          format.json do
            Rails.logger.debug "Rendering JSON error response"
            render json: { error: @error }, status: :unprocessable_entity
          end
          format.turbo_stream { render turbo_stream: turbo_stream.replace("query-results", partial: "sqlite_dashboard/databases/error", locals: { error: @error }) }
          format.html { redirect_to sqlite_dashboard_database_path(@database[:id]), alert: @error }
        end
      end
    end

    def tables
      @tables = @metadata.tables
      render json: tables
    end

    def table_info
      table_name = params[:table_name]
      @schema = @metadata.get_table_schema(table_name)
      @columns = @metadata.get_columns(table_name)
      @indexes = @metadata.get_indexes(table_name)
    end

    def export_csv
      query = params[:query]
      separator = params[:separator] || ','
      include_headers = params[:include_headers] == 'true'

      begin
        # Always forbid DROP and ALTER operations
        if contains_destructive_ddl?(query)
          render json: { error: "DROP and ALTER operations are forbidden for safety reasons." }, status: :unprocessable_entity
          return
        end

        # Check for DML operations if allow_dml is false
        unless SqliteDashboard.configuration.allow_dml
          if contains_dml?(query)
            render json: { error: "DML operations (INSERT, UPDATE, DELETE, CREATE, TRUNCATE) are not allowed." }, status: :unprocessable_entity
            return
          end
        end

        database_connection.results_as_hash = true
        results = database_connection.execute(query)

        if results.empty?
          render json: { error: "No data to export" }, status: :unprocessable_entity
          return
        end

        # Generate CSV
        csv_data = CSV.generate(col_sep: separator) do |csv|
          columns = results.first.keys
          csv << columns if include_headers

          results.each do |row|
            csv << row.values
          end
        end

        # Send as download
        send_data csv_data,
                  filename: "export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv",
                  type: 'text/csv',
                  disposition: 'attachment'
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    def export_json
      query = params[:query]
      format_type = params[:format] || 'array' # 'array' or 'object'
      pretty_print = params[:pretty_print] == 'true'

      begin
        # Always forbid DROP and ALTER operations
        if contains_destructive_ddl?(query)
          render json: { error: "DROP and ALTER operations are forbidden for safety reasons." }, status: :unprocessable_entity
          return
        end

        # Check for DML operations if allow_dml is false
        unless SqliteDashboard.configuration.allow_dml
          if contains_dml?(query)
            render json: { error: "DML operations (INSERT, UPDATE, DELETE, CREATE, TRUNCATE) are not allowed." }, status: :unprocessable_entity
            return
          end
        end

        database_connection.results_as_hash = true
        results = database_connection.execute(query)

        if results.empty?
          render json: { error: "No data to export" }, status: :unprocessable_entity
          return
        end

        # Generate JSON
        json_data = if format_type == 'object'
          # Format: { "columns": [...], "rows": [...] }
          columns = results.first.keys
          rows = results.map(&:values)
          data = { columns: columns, rows: rows }
          pretty_print ? JSON.pretty_generate(data) : data.to_json
        else
          # Format: array of objects
          pretty_print ? JSON.pretty_generate(results) : results.to_json
        end

        # Send as download
        send_data json_data,
                  filename: "export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json",
                  type: 'application/json',
                  disposition: 'attachment'
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    private

    def set_database
      @database = Work.all_databases.find { |db| db[:id] == params[:id].to_i }
      redirect_to sqlite_dashboard_databases_path, alert: "Database not found" unless @database
    end

    def set_metadata
      @metadata = SqliteMetadata.new(@database[:path])
    rescue => e
      Rails.logger.error "Failed to initialize SqliteMetadata: #{e.message}"
      redirect_to sqlite_dashboard_databases_path, alert: "Failed to access database: #{e.message}"
    end

    def database_connection
      @connection ||= SQLite3::Database.new(@database[:path])
    end

    def execute_sql(query)
      return { error: "Query cannot be empty" } if query.blank?

      # Always forbid DROP and ALTER operations
      if contains_destructive_ddl?(query)
        return { error: "DROP and ALTER operations are forbidden for safety reasons." }
      end

      # Check for DML operations if allow_dml is false
      unless SqliteDashboard.configuration.allow_dml
        if contains_dml?(query)
          return { error: "DML operations (INSERT, UPDATE, DELETE, CREATE, TRUNCATE) are not allowed. Set allow_dml to true in configuration to enable." }
        end
      end

      database_connection.results_as_hash = true
      results = database_connection.execute(query)

      if results.empty?
        { columns: [], rows: [], message: "Query executed successfully with no results" }
      else
        columns = results.first.keys
        rows = results.map(&:values)
        { columns: columns, rows: rows }
      end
    end

    def contains_destructive_ddl?(query)
      # Remove comments and normalize whitespace
      normalized_query = query.gsub(/--[^\n]*/, '').gsub(/\/\*.*?\*\//m, '').gsub(/\s+/, ' ').strip.upcase
      normalized_query =~ /\b(DROP|ALTER)\s+/
    end

    def contains_dml?(query)
      # Remove comments and normalize whitespace
      normalized_query = query.gsub(/--[^\n]*/, '').gsub(/\/\*.*?\*\//m, '').gsub(/\s+/, ' ').strip.upcase

      # Check for DML/DDL keywords (excluding DROP and ALTER which are always forbidden)
      dml_patterns = [
        /\bINSERT\s+INTO\b/,
        /\bUPDATE\s+/,
        /\bDELETE\s+FROM\b/,
        /\bCREATE\s+/,
        /\bTRUNCATE\s+/,
        /\bREPLACE\s+INTO\b/
      ]

      dml_patterns.any? { |pattern| normalized_query =~ pattern }
    end
  end
end

