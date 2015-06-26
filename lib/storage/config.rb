module Storage
  class Config
    class << self
      # Set a storage strategy based on its registered name.
      #
      #   Storage::Config.strategy = :s3
      #
      attr_accessor :strategy

      # Set a storage class.
      #
      #   Storage::Config.strategy_class = Storage::Strategies::S3
      #
      attr_accessor :strategy_class

      # Set the S3 default bucket.
      attr_accessor :bucket

      # Set the S3 access key.
      attr_accessor :access_key

      # Set the S3 secret key
      attr_accessor :secret_key

      # Set the FileSystem storage path.
      attr_accessor :path
    end

    # Override setter so we can automatically define the strategy class
    # based on its registered name.
    def self.strategy=(strategy)
      @strategy_class = get_class_for_strategy(strategy)
      @strategy = strategy
    end

    def self.get_class_for_strategy(strategy)
      Storage::Strategies::STRATEGIES[strategy].split('::')
        .reduce(Object) {|ns, class_name| ns.const_get(class_name) }
    end
  end
end
