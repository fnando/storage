require "bundler"
Bundler.setup
Bundler.require(:default, :development)

require "storage"
require "pathname"

TMP = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/tmp"))
RESOURCES = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/resources"))

RSpec.configure do |config|
  config.around :each do
    FileUtils.rm_rf(TMP) rescue nil
    FileUtils.mkdir_p(TMP) rescue nil
  end
end
