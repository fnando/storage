require "jeweler"
require "rake/rdoctask"
require "rspec/core/rake_task"
require "lib/storage/version"

desc "Default: run specs."
task :default => :spec

desc "Run the specs"
RSpec::Core::RakeTask.new do |t|
  t.rcov = true
  t.rcov_opts = %w[--exclude='.gem']
  t.ruby_opts = %w[-rubygems -Ilib -Ispec]
end

Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.title = "Storage"
  rdoc.options += %w[ --line-numbers --inline-source --charset utf-8 ]
  rdoc.rdoc_files.include("README.rdoc")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "storage"
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://github.com/fnando/storage"
  gem.authors = ["Nando Vieira"]
  gem.version = Storage::Version::STRING
  gem.summary = "This gem provides a simple API for multiple storage backends. Supported storages: Amazon S3 and FileSystem."
  gem.add_dependency "aws-s3"
  gem.files =  FileList["{README}.rdoc", "{lib,spec}/**/*"]
end

Jeweler::GemcutterTasks.new
