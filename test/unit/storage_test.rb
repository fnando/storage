require "test_helper"

class StorageTest < Minitest::Test
  test "returns the strategy" do
    strategy = mock("strategy")
    Storage::Config.strategy_class = strategy

    assert_equal strategy, Storage.strategy
  end

  test "returns the config" do
    Storage::Strategies::S3.stubs(:prepare!)
    config = nil

    Storage.setup do |actual_config|
      actual_config.strategy = :s3
      config = actual_config
    end

    assert_equal Storage::Config, config
  end

  test "sets strategy class based on its name" do
    Storage::Config.strategy_class = nil
    Storage::Config.strategy = :s3

    assert_equal Storage::Strategies::S3, Storage::Config.strategy_class
  end

  test "prepares strategy after setting its configuration" do
    Storage::Strategies::S3.expects(:prepare!).once
    Storage.setup {|config| config.strategy = :s3 }
  end
end
