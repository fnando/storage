require "spec_helper"

describe Storage::Strategies::S3 do
  before do
    @source = RESOURCES.join("file.txt")
    @destiny = TMP.join("lorem.txt")
    @bucket = mock("bucket", :name => "files")

    AWS::S3::Base.stub :establish_connection!
    AWS::S3::Bucket.stub :find => @bucket
    AWS::S3::S3Object.stub :store

    Storage.setup do |c|
      c.strategy = :s3
      c.access_key = "abc"
      c.secret_key = "123"
    end
  end

  it "should establish connection" do
    options = {:access_key_id => "abc", :secret_access_key => "123"}
    AWS::S3::Base.should_receive(:establish_connection!).with(options)

    Storage::Strategies::S3.connect!
  end

  it "should not reconnect when a connection is already established" do
    AWS::S3::Base.should_receive(:connected?).and_return(true)
    AWS::S3::Base.should_not_receive(:establish_connection!)

    Storage::Strategies::S3.connect!
  end

  it "should disconnect when connection is established" do
    AWS::S3::Base.should_receive(:connected?).and_return(true)
    AWS::S3::Base.should_receive(:disconnect!)
    Storage::Strategies::S3.disconnect!
  end

  it "should ignore disconnection when connection is not established" do
    AWS::S3::Base.should_receive(:connected?).and_return(false)
    AWS::S3::Base.should_not_receive(:disconnect!)
    Storage::Strategies::S3.disconnect!
  end

  it "should save a file using file handler" do
    handler = File.open(@source)
    AWS::S3::S3Object.should_receive(:store).with("lorem.txt", handler, "files", :access => :public_read)
    Storage.store(handler, :name => "lorem.txt", :bucket => "files")
  end

  it "should save a file using a path" do
    AWS::S3::S3Object.should_receive(:store).with("lorem.txt", kind_of(File), "files", :access => :public_read)
    Storage.store(@source, :name => "lorem.txt", :bucket => "files")
  end

  it "should remove an existing file" do
    object = mock("object")
    object.should_receive(:delete).and_return(true)
    Storage::Strategies::S3.should_receive(:find_object).with("lorem.txt", :bucket => "files").and_return(object)

    Storage.remove("lorem.txt", :bucket => "files").should be_true
  end

  it "should raise when trying to removing an unexesting file" do
    Storage::Strategies::S3.should_receive(:find_object).and_raise(AWS::S3::NoSuchKey)

    expect {
      Storage.remove("lorem.txt", :bucket => "files")
    }.to raise_error(Storage::MissingFileError)
  end

  it "should retrieve an existing file" do
    object = mock("object")

    AWS::S3::S3Object.should_receive(:find).with("lorem.txt", "files").and_return(object)
    AWS::S3::S3Object.should_receive(:url_for).with("lorem.txt", "files", :authenticated => false)

    Storage.get("lorem.txt", :bucket => "files")
  end

  it "should raise when trying to retrieve an unexesting file" do
    AWS::S3::S3Object.should_receive(:find).with("lorem.txt", "files").and_raise(AWS::S3::NoSuchKey)
    AWS::S3::S3Object.should_not_receive(:url_for)

    expect {
      Storage.get("lorem.txt", :bucket => "files")
    }.to raise_error(Storage::MissingFileError)
  end

  it "should raise when saving a file that already exists" do
    object = mock("object")
    options = {:name => "lorem.txt", :bucket => "files"}
    Storage::Strategies::S3.should_receive(:find_object).with(@source, options).and_return(object)

    expect {
      Storage.store(@source, :name => "lorem.txt", :bucket => "files")
    }.to raise_error(Storage::FileAlreadyExistsError)
  end
end
