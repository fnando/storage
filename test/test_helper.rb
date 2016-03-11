require "bundler/setup"

require "storage"
require "pathname"

require "minitest/utils"
require "minitest/autorun"
require "mocha"
require "mocha/mini_test"

TMP = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/tmp"))
RESOURCES = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/resources"))

class Minitest::Test
  setup do
    FileUtils.rm_rf(TMP) rescue nil
    FileUtils.mkdir_p(TMP) rescue nil
  end
end

class NullObject
  def initialize(*)
  end

  def method_missing(*)
    self
  end
end
