require "spec_helper"

describe Storage do
  it "should return the strategy" do
    @strategy = double("strategy")
    Storage::Config.strategy_class = @strategy

    expect(Storage.strategy).to be(@strategy)
  end

  it "should return the config" do
    allow(Storage::Strategies::S3).to receive :prepare!

    Storage.setup do |config|
      config.strategy = :s3
      expect(config).to be(Storage::Config)
    end
  end

  it "should set strategy class based on its name" do
    Storage::Config.strategy_class = nil
    Storage::Config.strategy = :s3

    expect(Storage::Config.strategy_class).to eq(Storage::Strategies::S3)
  end

  it "prepare strategy after setting its configuration" do
    expect(Storage::Strategies::S3).to receive(:prepare!).once
    Storage.setup {|config| config.strategy = :s3}
  end

  context "delegation" do
    before do
      @strategy = double("strategy")
      expect(Storage).to receive(:strategy).and_return(@strategy)
    end

    it "should delegate save method" do
      expect(@strategy).to receive(:store).with("some/file")
      Storage.store "some/file"
    end

    it "should delegate destroy method" do
      expect(@strategy).to receive(:remove).with("some/file")
      Storage.remove "some/file"
    end

    it "should delegate get method" do
      expect(@strategy).to receive(:get).with("some/file")
      Storage.get "some/file"
    end
  end
end
