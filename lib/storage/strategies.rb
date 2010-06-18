module Storage
  module Strategies
    autoload :S3,           "storage/strategies/s3"
    autoload :FileSystem,   "storage/strategies/file_system"

    STRATEGIES = {}

    # Register a new strategy.
    def self.register(name, klass)
      STRATEGIES[name] = klass.to_s
    end
  end
end
