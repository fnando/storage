require "test_helper"

module S3StrategyTest
  class RegionTest < Minitest::Test
    setup do
      Storage.setup do |c|
        c.strategy = :s3
        c.access_key = "AKIAIOSFODNN7EXAMPLE"
        c.secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      end
    end

    test "sets default region" do
      Storage::Config.region = nil
      assert_equal "us-east-1", Storage::Strategies::S3.connection.region
    end

    test "sets custom region" do
      Storage::Config.region = "eu-west-1"
      assert_equal "eu-west-1", Storage::Strategies::S3.connection.region
    end
  end

  class GeneralTest < Minitest::Test
    let(:adapter) { Storage::Strategies::S3 }
    let(:source) { RESOURCES.join("file.txt") }
    let(:destiny) { TMP.join("lorem.txt") }
    let(:connection) { mock("connection") }
    let(:bucket) { mock("bucket") }

    setup do
      adapter.stubs(:connection).returns(connection)

      Storage.setup do |c|
        c.strategy = :s3
        c.access_key = "abc"
        c.secret_key = "123"
        c.region = "us-east-1"
      end
    end

    test "saves a file using file handler" do
      handler = File.open(source)
      setup_create_object

      Storage.store(handler, name: "lorem.txt", bucket: "files")
    end

    test "saves a file using a path" do
      setup_create_object
      Storage.store(source, name: "lorem.txt", bucket: "files")
    end

    test "removes an existing file" do
      object = mock("object")

      setup_get_object object: object
      object.expects(:destroy).returns(true)

      assert Storage.remove("lorem.txt", bucket: "files")
    end

    test "raises when trying to removing an nonexisting file" do
      setup_get_object object: nil

      assert_raises(Storage::MissingFileError) {
        Storage.remove("lorem.txt", bucket: "files")
      }
    end

    test "retrieves an existing file (public url)" do
      object = mock("object", public_url: "PUBLIC_URL")

      setup_get_object object: object

      assert_equal "PUBLIC_URL", Storage.get("lorem.txt", bucket: "files")
    end

    test "retrieves an existing file with default expiration [private url]" do
      Time.stubs(:now).returns(Time.now)

      object = mock("object", public_url: nil)
      object.expects(:url).with(Time.now.to_i + 3600).returns("PRIVATE_URL")

      Storage::Strategies::S3.stubs(:find_object).returns(object)

      assert_equal "PRIVATE_URL", Storage.get("lorem.txt", bucket: "files")
    end

    test "retrieves an existing file with custom expiration [private url]" do
      Time.stubs(:now).returns(Time.now)

      object = mock("object", public_url: nil)
      object.expects(:url).with(Time.now.to_i + 60).returns("PRIVATE_URL")

      Storage::Strategies::S3.stubs(:find_object).returns(object)

      private_url = Storage.get("lorem.txt",
                                bucket: "files",
                                expires: Time.now.to_i + 60)

      assert_equal "PRIVATE_URL", private_url
    end

    test "raises when trying to retrieve an missing file" do
      setup_get_object object: nil

      assert_raises(Storage::MissingFileError) {
        Storage.get("lorem.txt", bucket: "files")
      }
    end

    test "raises when trying to retrieve an missing bucket" do
      setup_get_bucket bucket: nil

      assert_raises(Storage::MissingFileError) {
        Storage.get("lorem.txt", bucket: "files")
      }
    end

    test "creates a bucket when trying to store a file on a missing bucket" do
      null_object = NullObject.new
      bucket.stubs(:files).returns(null_object)
      setup_create_bucket

      Storage.store(source, name: "lorem.txt", bucket: "files")
    end

    test "sets file permission to public" do
      setup_create_object public: true
      Storage.store(source, name: "lorem.txt", bucket: "files", public: true)
    end

    test "sets file permission to private (default)" do
      setup_create_object public: false
      Storage.store(source, name: "lorem.txt", bucket: "files")
    end

    test "sets file permission to private" do
      setup_create_object public: false
      Storage.store(source, name: "lorem.txt", bucket: "files", public: false)
    end

    test "sets file permission to private (access option)" do
      setup_create_object public: false
      Storage.store(source, name: "lorem.txt", bucket: "files", access: :private)
    end

    test "sets file permission to public (access option)" do
      setup_create_object public: true
      Storage.store(source, name: "lorem.txt", bucket: "files", access: :public_read)
    end

    def setup_create_object(bucket: self.bucket, object: nil, public: false, file_name: "lorem.txt")
      # 1. first find bucket.
      setup_get_bucket(bucket: bucket)

      # 2. create file
      params = {key: file_name, body: instance_of(File), public: public}

      files = stub("files")
      files.expects(:create).with(has_entries(params)).returns(object)
      bucket.stubs(:files).returns(files)
    end

    def setup_get_object(bucket: self.bucket, file_name: "lorem.txt", object: nil)
      # 1. Set up connection.directories.get
      setup_get_bucket(bucket: bucket)

      # 2. Set up bucket.files.get
      files = stub("files")
      files.expects(:get).with(file_name).returns(object)
      bucket.expects(:files).returns(files)
    end

    def setup_create_bucket(bucket: nil)
      get = stub("get")
      get.expects(:get).with("files").returns(bucket)

      create = stub("create")
      create.expects(:create).with(key: "files", public: false).returns(self.bucket)

      connection.stubs(:directories).returns(get, create)
    end

    def setup_get_bucket(bucket: self.bucket)
      dir = stub("directories")
      dir.expects(:get).with("files").returns(bucket)
      connection.expects(:directories).at_least_once.returns(dir)
    end
  end
end
