require "spec_helper"

describe Storage::Strategies::S3 do
  context "region" do
    before do
      Storage.setup do |c|
        c.strategy = :s3
        c.access_key = "AKIAIOSFODNN7EXAMPLE"
        c.secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      end
    end

    it "sets default region" do
      Storage::Config.region = nil
      expect(Storage::Strategies::S3.connection.region).to eq("us-east-1")
    end

    it "sets custom region" do
      Storage::Config.region = "eu-west-1"
      expect(Storage::Strategies::S3.connection.region).to eq("eu-west-1")
    end
  end

  context "general" do
    let(:adapter) { Storage::Strategies::S3 }
    let(:source) { RESOURCES.join("file.txt") }
    let(:destiny) { TMP.join("lorem.txt") }
    let(:connection) { double("connection") }
    let(:bucket) { double("bucket") }

    before do
      allow(adapter).to receive(:connection).and_return(connection)

      Storage.setup do |c|
        c.strategy = :s3
        c.access_key = "abc"
        c.secret_key = "123"
        c.region = "us-east-1"
      end
    end

    it "should save a file using file handler" do
      handler = File.open(source)
      setup_create_object

      Storage.store(handler, name: "lorem.txt", bucket: "files")
    end

    it "should save a file using a path" do
      setup_create_object
      Storage.store(source, name: "lorem.txt", bucket: "files")
    end

    it "should remove an existing file" do
      object = double("object")

      setup_get_object object: object
      expect(object).to receive(:destroy).and_return(true)

      expect(Storage.remove("lorem.txt", bucket: "files")).to be_truthy
    end

    it "should raise when trying to removing an nonexisting file" do
      setup_get_object object: nil

      expect {
        Storage.remove("lorem.txt", bucket: "files")
      }.to raise_error(Storage::MissingFileError)
    end

    it "should retrieve an existing file (public url)" do
      object = double("object", public_url: "PUBLIC_URL")

      setup_get_object object: object

      expect(Storage.get("lorem.txt", bucket: "files")).to eq("PUBLIC_URL")
    end

    it "should retrieve an existing file (private url)" do
      object = double("object", public_url: nil)

      expect(object).to receive_message_chain("url").with(Time.now.to_i + 3600).and_return("PRIVATE_URL")
      setup_get_object object: object

      expect(Storage.get("lorem.txt", bucket: "files")).to eq("PRIVATE_URL")
    end

    it "should raise when trying to retrieve an missing file" do
      setup_get_object object: nil

      expect {
        Storage.get("lorem.txt", bucket: "files")
      }.to raise_error(Storage::MissingFileError)
    end

    it "should raise when trying to retrieve an missing bucket" do
      setup_get_bucket bucket: nil

      expect {
        Storage.get("lorem.txt", bucket: "files")
      }.to raise_error(Storage::MissingFileError)
    end

    it "should create a bucket when trying to store a file on a missing bucket" do
      bucket.as_null_object
      setup_create_bucket

      Storage.store(source, name: "lorem.txt", bucket: "files")
    end

    it "should set file permission to public" do
      setup_create_object public: true
      Storage.store(source, name: "lorem.txt", bucket: "files", public: true)
    end

    it "should set file permission to private (default)" do
      setup_create_object public: false
      Storage.store(source, name: "lorem.txt", bucket: "files")
    end

    it "should set file permission to private" do
      setup_create_object public: false
      Storage.store(source, name: "lorem.txt", bucket: "files", public: false)
    end

    it "should set file permission to private (access option)" do
      setup_create_object public: false
      Storage.store(source, name: "lorem.txt", bucket: "files", access: :private)
    end

    it "should set file permission to public (access option)" do
      setup_create_object public: true
      Storage.store(source, name: "lorem.txt", bucket: "files", access: :public_read)
    end

    def setup_create_object(bucket: self.bucket, object: nil, public: false, file_name: "lorem.txt")
      allow(connection).to receive_message_chain("directories.get").with("files").and_return(bucket)
      expect(bucket).to receive_message_chain("files.create").with(key: file_name, body: kind_of(File), public: public)
    end

    def setup_get_object(bucket: self.bucket, file_name: "lorem.txt", object: nil)
      expect(connection).to receive_message_chain("directories.get").with("files").and_return(bucket)
      expect(bucket).to receive_message_chain("files.get").with(file_name).and_return(object)
    end

    def setup_create_bucket(bucket: nil)
      allow(connection).to receive_message_chain("directories.get").with("files").and_return(bucket)
      expect(connection).to receive_message_chain("directories.create").with(key: "files", public: false).and_return(self.bucket)
    end

    def setup_get_bucket(bucket: self.bucket)
      allow(connection).to receive_message_chain("directories.get").with("files").and_return(bucket)
    end
  end
end
