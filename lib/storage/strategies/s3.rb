module Storage
  module Strategies
    module S3
      extend self

      MissingBucket = Class.new(StandardError)

      def connection
        @connection ||= Fog::Storage.new(
          provider: "AWS",
          aws_access_key_id: Storage::Config.access_key,
          aws_secret_access_key: Storage::Config.secret_key,
          region: Storage::Config.region
        )
      end

      def prepare!
        disconnect!
      end

      def connect!
      end

      def disconnect!
        @connection = nil
      end

      def get(file, options = {})
        expires = options.fetch(:expires, Time.now.to_i + 3600)
        object = find_object(file, options)
        object.public_url || object.url(expires)
      end

      def store(file, options = {})
        object = find_object(file, options) rescue nil
        fail FileAlreadyExistsError if object

        bucket = find_bucket_or_create(options.fetch(:bucket))
        file = File.open(file, "rb") unless file.respond_to?(:read) && !file.kind_of?(Pathname)

        create_object(bucket, file, options)
      end

      def remove(file, options = {})
        object = find_object(file, options)
        object.destroy
      end

      def find_bucket(name)
        connection.directories.get(name)
      end

      def find_bucket!(name)
        find_bucket(name) || fail(MissingBucket)
      end

      def create_bucket(name)
        connection.directories.create(
          key: name,
          public: false
        )
      end

      def create_object(bucket, file, options)
        bucket.files.create(
          key: options.fetch(:name),
          body: file,
          public: (options[:public] || options[:access] == :public_read)
        )
      end

      def find_object(file, options = {})
        path = options.fetch(:name, file)
        bucket = find_bucket!(options.fetch(:bucket))
        bucket.files.get(path) || fail(MissingFileError)
      rescue MissingBucket
        raise MissingFileError
      end

      def find_bucket_or_create(name)
        find_bucket(name) || create_bucket(name)
      end
    end
  end
end
