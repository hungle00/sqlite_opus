# Require configuration file
# Use require_relative to ensure it works when autoload is not available
require_relative "sqlite_dashboard/configuration"

module SqliteDashboard
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
