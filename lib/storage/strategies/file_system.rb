module Storage
  module Strategies
    module FileSystem
      extend self

      def prepare!
        FileUtils.mkdir_p File.expand_path(Storage::Config.path)
      end

      def fullpath(file)
        File.expand_path File.join(Storage::Config.path, file)
      end

      def get(file, *noop)
        prepare!
        path = fullpath(file)
        raise Storage::MissingFileError unless File.file?(path)
        path
      end

      def remove(file, *noop)
        prepare!
        path = get(file)
        File.unlink(path)
      end

      def store(file, options = {})
        prepare!
        file = File.open(file, "rb") unless file.respond_to?(:read) && !file.kind_of?(Pathname)
        path = fullpath(options[:name])

        raise Storage::FileAlreadyExistsError if File.file?(path)

        File.open(path, "wb") do |handler|
          while line = file.gets
            handler.write line
          end
        end
      end
    end
  end
end
