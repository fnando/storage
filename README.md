# Storage

This gem provides a simple API for multiple storage backends. Supported storages: Amazon S3 and FileSystem (it uses Fog under the hood).

The storage provides only 3 methods, one for each operation: `Storage::get`, `Storage::store` and `Storage::remove`.

## Installation

    gem install storage

You can get source code at http://github.com/fnando/storage

## Usage

```ruby
require "storage"
```

You basically use the same method no matter what storage strategy you're using.

### Amazon S3

```ruby
Storage.setup do |config|
  config.strategy    = :s3
  config.access_key  = "abcdef"
  config.secret_key  = "123456"
end

# Store a local file on S3.
# You can easily switch from S3 to FileSystem; 
# keys that are not used by one strategy is simply ignored.
Storage.store "some/file.rb", name: "file.rb", bucket: "sample"
Storage.store File.open("some/file.rb"), name: "file.rb", bucket: "sample", public: true

# Retrieve the public url for that file
Storage.get "file.rb", bucket: "sample"
#=> http://s3.amazon.com/sample-files/file.rb

# Retrieve the public url for a private file,
# setting expiration to 5 minutes (300 seconds).
Storage.get "private.rb", bucket: "sample", expires: Time.now.to_i + 300

# Remove a file.
Storage.remove "file.rb", bucket: "sample"
```

### FileSystem

```ruby
Storage.setup do |config|
  config.strategy   = :file
  config.path       = "some/directory"
end

# Store a file.
Storage.store "some/file.rb", name: "file.rb"
Storage.store File.open("some/file.rb"), name: "file.rb"

# Retrieve that file's path.
Storage.get "file.rb"
#=> some/directory/file.rb

# Remove a file.
Storage.remove "file.rb"
```

## License

(The MIT License)

Copyright © 2010:

* Nando Vieira (http://nandovieira.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
