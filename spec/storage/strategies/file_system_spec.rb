require "spec_helper"

describe Storage::Strategies::FileSystem do
  before do
    @source = RESOURCES.join("file.txt")
    @destiny = TMP.join("lorem.txt")

    Storage.setup do |c|
      c.strategy = :file
      c.path = TMP
    end
  end

  it "should save a file using file handler" do
    handler = File.open(@source)
    Storage.store(handler, :name => "lorem.txt")

    File.should be_file(@destiny)
    File.read(@destiny).should == File.read(@source)
  end

  it "should save a file using a path" do
    Storage.store(@source, :name => "lorem.txt")

    File.should be_file(@destiny)
    File.read(@destiny).should == File.read(@source)
  end

  it "should remove an existing file" do
    Storage.store(@source, :name => "lorem.txt")
    Storage.remove("lorem.txt").should be_true
    File.should_not be_file(@destiny)
  end

  it "should raise when trying to removing an unexesting file" do
    expect {
      Storage.remove("invalid")
    }.to raise_error(Storage::MissingFileError)
  end

  it "should retrieve an existing file" do
    Storage.store(@source, :name => "lorem.txt")
    Storage.get("lorem.txt").should == File.expand_path(TMP.join("lorem.txt"))
  end

  it "should raise when trying to retrieve an unexesting file" do
    expect {
      Storage.get("invalid")
    }.to raise_error(Storage::MissingFileError)
  end

  it "should raise when saving a file that already exists" do
    Storage.store(@source, :name => "lorem.txt")

    expect {
      Storage.store(@source, :name => "lorem.txt")
    }.to raise_error(Storage::FileAlreadyExistsError)
  end
end
