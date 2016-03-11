require "test_helper"

class DelegationTest < Minitest::Test
  setup do
    @strategy = mock("strategy")
    Storage.expects(:strategy).returns(@strategy)
  end

  test "delegate save method" do
    @strategy.expects(:store).with("some/file")
    Storage.store "some/file"
  end

  test "delegate destroy method" do
    @strategy.expects(:remove).with("some/file")
    Storage.remove "some/file"
  end

  test "delegate get method" do
    @strategy.expects(:get).with("some/file")
    Storage.get "some/file"
  end
end
