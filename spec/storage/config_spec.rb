require "spec_helper"

describe Storage::Config do
  it "should set strategy class based on its name" do
    Storage::Config.strategy_class = nil
    Storage::Config.strategy = :s3
    
    Storage::Config.strategy_class.should == Storage::Strategies::S3
  end
end
