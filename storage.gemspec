# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "storage/version"

Gem::Specification.new do |s|
  s.name        = "storage"
  s.version     = Storage::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://github.com/fnando/storage"
  s.summary     = "This gem provides a simple API for multiple storage backends. Supported storages: Amazon S3 and FileSystem."
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "aws-s3", "~> 0.6.2"

  s.add_development_dependency "rails"        , "~> 3.1"
  s.add_development_dependency "fakeweb"      , "~> 1.3.0"
  s.add_development_dependency "rspec-rails"  , "~> 2.7.0"
  s.add_development_dependency "nokogiri"     , "~> 1.4.4"
  s.add_development_dependency "sqlite3"      , "~> 1.3.3"
  s.add_development_dependency "pry"
end
