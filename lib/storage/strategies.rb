module Storage
  module Strategies
    require "storage/strategies/s3"
    require "storage/strategies/file_system"

    STRATEGIES = {}

    # Register a new strategy.
    def self.register(name, klass)
      STRATEGIES[name] = klass.to_s
    end
  end
end
