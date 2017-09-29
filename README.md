mongoid-gitifield
=================

Mongoid-gitifield provides version control on your mongoid document field with git (the real git), gitify your field. Facilitating features from git to keep track on your changes, diff from versions and ability to update the value by applying patch. This gem stores a git repositroy (seriously) for each field you keep track on, encoded and stored within your document. It is not suitable for use cases that require search on changes or index.

Install
-------

Add this to your `Gemfile`

```ruby
gem 'mongoid-gitifield', git: 'https://github.com/Seitk/mongoid-gitifield.git'
```

And then run `bundle install`.

Usage
-----

```ruby
# app/models/post.rb
class Post
  include Mongoid::Document
  include Mongoid::Gitifield

  field :summary, type: String
  field :content, type: String

  # Specify fields to track
  gitifields_on   %i(summary content)
end
```

After that, gitifield workspace is generated for each field giving you access to the field repository `XXXX_gitifield`. Also when a document is created or updated, the gem will automatically commit new value to the field repository. Then the repositroy is pack in gziped tar, base64 encoded and save back into `attributes` with key `XXXX_gitifield_data`.   

```ruby
# Generated interface
post.summary_gitifield
post.content_gitifield

# Raw data stored in attributes
post[:summary_gitifield_data]
post[:content_gitifield_data]
```

Feature
-------

```ruby
# Get commit sha of current value
post.summary_gitifield.id

# Accessing current value of the field repository
post.summary_gitifield.content

# Update the value and commit right a way
post.summary_gitifield.update('<article><h1>Breaking News: Your cat can pick up on how you are feeling</h1></article>')

# Show commit logs
post.summary_gitifield.logs
# => [
#      {:id=>"8a78ab758b352e12cfc72a4a26ed0750c588006d", :date=>2017-09-30 11:02:16 +0000},
#      {:id=>"7df66c7f6d786699a7a972163aa70daaf406380c", :date=>2017-09-30 10:30:08 +0000},
#      {:id=>"0ce3a1ec9b46c892a714647dd3971e3dc1558fd0", :date=>2017-09-30 10:05:23 +0000},
#      {:id=>"8cba3b0a7a5d97a7081b12d1b2438b20258d01d8", :date=>2017-09-30 10:00:44 +0000}
#    ]

# Checkout to a specific commit
post.summary_gitifield.checkout('8a78ab758b352e12cfc72a4a26ed0750c588006d')

# Revert to a commit (we don't change history, it creates a new commit with the value instead)
post.summary_gitifield.revert('0ce3a1ec9b46c892a714647dd3971e3dc1558fd0')

# Apply patch from file
post.summary_gitifield.apply_patch(Dir.tmpdir.join('patch_001.diff'))

# Also, you can directly access to the git repository (thanks to ruby-git gem)
post.summary_gitifield.git
post.summary_gitifield.git.status
```

That is how it looks if you check the repository
![Alt text](https://storage.googleapis.com/philip-test/gitifield.png "The field repository")


Contributing to this project
----------------------------

Pull requests, feature requests and issue reportings are alwasy welcome and greatly appreciated.

Copyright
---------

MIT License. See LICENSE for further details.