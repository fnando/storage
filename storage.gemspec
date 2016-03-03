require "./lib/storage/version"

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
  s.executables   = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "fog"
  s.add_dependency "mime-types"

  s.add_development_dependency "rspec"
  s.add_development_dependency "pry-meta"
end
