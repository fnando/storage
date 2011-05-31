require "spec_helper"

describe Storage do
  it "should return the strategy" do
    @strategy = mock("strategy")
    Storage::Config.strategy_class = @strategy

    Storage.strategy.should be(@strategy)
  end

  it "should return the config" do
    Storage::Strategies::S3.stub :prepare!

    Storage.setup do |config|
      config.strategy = :s3
      config.should be(Storage::Config)
    end
  end

  it "prepare strategy after setting its configuration" do
    Storage::Strategies::S3.should_receive(:prepare!).once
    Storage.setup {|config| config.strategy = :s3}
  end

  context "delegation" do
    before do
      @strategy = mock("strategy")
      Storage.should_receive(:strategy).and_return(@strategy)
    end

    it "should delegate save method" do
      @strategy.should_receive(:store).with("some/file")
      Storage.store "some/file"
    end

    it "should delegate destroy method" do
      @strategy.should_receive(:remove).with("some/file")
      Storage.remove "some/file"
    end

    it "should delegate get method" do
      @strategy.should_receive(:get).with("some/file")
      Storage.get "some/file"
    end
  end
end
