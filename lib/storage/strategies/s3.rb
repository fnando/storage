module Storage
  module Strategies
    module S3
      extend self

      def connect!
        AWS::S3::Base.establish_connection!({
          :access_key_id     => Storage::Config.access_key,
          :secret_access_key => Storage::Config.secret_key
        }) unless AWS::S3::Base.connected?
      end

      def get(file, options = {})
        connect!
        object = find_object(file, options)
        AWS::S3::S3Object.url_for(file, options[:bucket], :authenticated => false)
      rescue AWS::S3::NoSuchKey, AWS::S3::NoSuchBucket
        raise Storage::MissingFileError
      end

      def store(file, options = {})
        connect!
        object = find_object(file, options) rescue nil

        raise Storage::FileAlreadyExistsError if object

        bucket = find_bucket_or_create(options[:bucket])
        file = File.open(file, "rb") unless file.respond_to?(:read) && !file.kind_of?(Pathname)
        AWS::S3::S3Object.store(options[:name], file, bucket.name, :access => options.fetch(:access, :public_read))
      end

      def remove(file, options = {})
        connect!
        object = find_object(file, options)
        object.delete
      rescue AWS::S3::NoSuchKey, AWS::S3::NoSuchBucket
        raise Storage::MissingFileError
      end

      def find_bucket(name)
        AWS::S3::Bucket.find(name)
      end

      def find_object(file, options = {})
        AWS::S3::S3Object.find(file, options[:bucket])
      end

      def find_bucket_or_create(name)
        bucket = find_bucket(name)
        bucket ||= AWS::S3::Bucket.create(name)
        bucket
      end
    end
  end
end
