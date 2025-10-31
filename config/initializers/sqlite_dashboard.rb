# SQLite Dashboard Configuration
#
# Configure which SQLite databases you want to access through the dashboard.
# Only configure databases you trust, as this provides direct SQL access.

# Require the SqliteDashboard module before configuring
# Since initializers run before autoload, we need to explicitly require
# Add lib to load path if not already there
$LOAD_PATH.unshift(Rails.root.join("lib").to_s) unless $LOAD_PATH.include?(Rails.root.join("lib").to_s)
require "sqlite_dashboard"

SqliteDashboard.configure do |config|
#   # =============================================================================
#   # Database Configuration
#   # =============================================================================

#   # Array of database configurations
#   # Each database should have a name and path
  config.db_files = [
    
    {
      name: "Development",
      path: Rails.root.join("storage", "development.sqlite3").to_s
    },
    
    {
      name: "Test",
      path: Rails.root.join("storage", "test.sqlite3").to_s
    }
    
  ]

  # You can also add databases dynamically:
  # config.add_database("Custom DB", "/path/to/custom.sqlite3")

  # If no databases are configured, SQLite Dashboard will automatically
  # detect and use SQLite databases from config/database.yml for the current environment

  # =============================================================================
  # Security Configuration
  # =============================================================================

  # Allow DML operations (INSERT, UPDATE, DELETE, CREATE, TRUNCATE)
  # Default: false (read-only mode)
  # Note: DROP and ALTER are always forbidden for safety
  config.allow_dml = false

  # Set to true to allow INSERT, UPDATE, DELETE, CREATE, TRUNCATE operations
  # config.allow_dml = true

  # =============================================================================
  # Production Security Note
  # =============================================================================
  #
  # For production use, wrap the mount in authentication:
  #
  # In config/routes.rb:
  # authenticate :user, ->(user) { user.admin? } do
  #   mount SqliteDashboard::Engine => "/sqlite_dashboard"
  # end
  #
  # Or use HTTP Basic Auth (add to config/application.rb or an initializer):
  # SqliteDashboard::Engine.middleware.use Rack::Auth::Basic do |user, pass|
  #   ActiveSupport::SecurityUtils.secure_compare(user, ENV['DASHBOARD_USER']) &
  #   ActiveSupport::SecurityUtils.secure_compare(pass, ENV['DASHBOARD_PASS'])
  # end
end