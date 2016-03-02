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
    before do
      @adapter = Storage::Strategies::S3
      @source = RESOURCES.join("file.txt")
      @destiny = TMP.join("lorem.txt")
      @connection = double("connection")
      @bucket = double("bucket")

      allow(@adapter).to receive(:connection).and_return(@connection)

      Storage.setup do |c|
        c.strategy = :s3
        c.access_key = "abc"
        c.secret_key = "123"
        c.region = "us-east-1"
      end
    end

    it "should save a file using file handler" do
      handler = File.open(@source)

      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@adapter).to receive_message_chain('find_object').and_return(nil)
      expect(@bucket).to receive_message_chain('files.create').with(:key => 'lorem.txt', :body => handler, :public => true)

      Storage.store(handler, :name => "lorem.txt", :bucket => "files")
    end

    it "should save a file using a path" do
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@adapter).to receive_message_chain('find_object').and_return(nil)
      expect(@bucket).to receive_message_chain('files.create').with(:key => 'lorem.txt', :body => kind_of(File), :public => true)

      Storage.store(@source, :name => "lorem.txt", :bucket => "files")
    end

    it "should remove an existing file" do
      object = double("object")
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@bucket).to receive_message_chain('files.get').with('lorem.txt').and_return(object)
      expect(object).to receive(:destroy).and_return(true)

      expect(Storage.remove("lorem.txt", :bucket => "files")).to be_truthy
    end

    it "should raise when trying to removing an unexesting file" do
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@bucket).to receive_message_chain('files.get').with('lorem.txt').and_return(nil)

      expect {
        Storage.remove("lorem.txt", :bucket => "files")
      }.to raise_error(Storage::MissingFileError)
    end

    it "should retrieve an existing file (public url)" do
      object = double("object", public_url: 'PUBLIC_URL')
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@bucket).to receive_message_chain('files.get').with('lorem.txt').and_return(object)

      expect(Storage.get("lorem.txt", :bucket => "files")).to eq('PUBLIC_URL')
    end

    it "should retrieve an existing file (private url)" do
      object = double("object", public_url: nil)

      expect(object).to receive_message_chain('url').with(Time.now.to_i + 3600).and_return('PRIVATE_URL')
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@bucket).to receive_message_chain('files.get').with('lorem.txt').and_return(object)

      expect(Storage.get("lorem.txt", :bucket => "files")).to eq('PRIVATE_URL')
    end

    it "should raise when trying to retrieve an missing file" do
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@bucket).to receive_message_chain('files.get').with('lorem.txt').and_return(nil)

      expect {
        Storage.get("lorem.txt", :bucket => "files")
      }.to raise_error(Storage::MissingFileError)
    end

    it "should raise when trying to retrieve an missing bucket" do
      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(nil)

      expect {
        Storage.get("lorem.txt", :bucket => "files")
      }.to raise_error(Storage::MissingFileError)
    end

    it "should create a bucket and trying to store a file on a missing bucket" do
      expect(@adapter).to receive_message_chain('find_object').and_return(nil)
      allow(@connection).to receive_message_chain('directories.get').and_return(nil)
      expect(@connection).to receive_message_chain('directories.create').with(key: 'files', public: false).and_return(@bucket)

      @bucket.as_null_object

      Storage.store(@source, :name => 'lorem.txt', :bucket => "files")
    end

    it "should raise when saving a file that already exists" do
      object = double("object")

      expect(@connection).to receive_message_chain('directories.get').with('files').and_return(@bucket)
      expect(@bucket).to receive_message_chain('files.get').with('lorem.txt').and_return(object)

      expect {
        Storage.store(@source, :name => 'lorem.txt', :bucket => 'files')
      }.to raise_error(Storage::FileAlreadyExistsError)
    end
  end
end
