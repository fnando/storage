require "rspec"
require "storage"
require "fileutils"
require "pathname"

TMP = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/tmp"))
RESOURCES = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/resources"))

RSpec.configure do |config|
  config.formatter = "documentation"
  config.color_enabled = true

  config.before :each do
    FileUtils.rm_rf(TMP) rescue nil
    FileUtils.mkdir_p(TMP) rescue nil
  end

  config.after :each do
    FileUtils.rm_rf(TMP) rescue nil
  end
end
