require "test_helper"

class FileSystemStrategyTest < Minitest::Test
  let(:source) { RESOURCES.join("file.txt") }
  let(:destiny) { TMP.join("lorem.txt") }

  setup do
    Storage.setup do |c|
      c.strategy = :file
      c.path = TMP
    end
  end

  test "saves a file using file handler" do
    handler = File.open(source)
    Storage.store(handler, name: "lorem.txt")

    assert File.file?(destiny)
    assert_equal File.read(source), File.read(destiny)
  end

  test "save a file using a path" do
    Storage.store(source, name: "lorem.txt")

    assert File.file?(destiny)
    assert_equal File.read(source), File.read(destiny)
  end

  test "remove an existing file" do
    Storage.store(source, name: "lorem.txt")

    assert Storage.remove("lorem.txt")
    refute File.file?(destiny)
  end

  test "raise when trying to removing an unexesting file" do
    assert_raises(Storage::MissingFileError) {
      Storage.remove("invalid")
    }
  end

  test "retrieve an existing file" do
    Storage.store(source, name: "lorem.txt")
    assert_equal File.expand_path(TMP.join("lorem.txt")), Storage.get("lorem.txt")
  end

  test "raise when trying to retrieve an unexesting file" do
    assert_raises(Storage::MissingFileError) {
      Storage.get("invalid")
    }
  end
end
