require "ostruct"
require "fileutils" unless defined?(FileUtils)
require "storage/errors"
require "aws/s3"

module Storage
  autoload :Config,       "storage/config"
  autoload :Strategies,   "storage/strategies"
  autoload :Version,      "storage/version"

  # Set up the storage options.
  #
  #   Storage.setup do |config|
  #     config.strategy = :s3
  #   end
  #
  # Check Storage::Config for available options.
  #
  def self.setup(&block)
    yield Config
  end

  # A shortcut to the current strategy.
  def self.strategy
    Config.strategy_class
  end

  # Save a file.
  def self.store(*args)
    strategy.store(*args)
  end

  # Destroy a file.
  def self.remove(*args)
    strategy.remove(*args)
  end

  # Retrieve a file.
  def self.get(*args)
    strategy.get(*args)
  end
end

Storage::Strategies.register :s3,     Storage::Strategies::S3
Storage::Strategies.register :file,   Storage::Strategies::FileSystem
