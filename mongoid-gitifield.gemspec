$:.unshift File.expand_path('../lib', __FILE__)

require 'mongoid/gitifield/version'

Gem::Specification.new do |s|
  s.name        = 'mongoid-gitifield'
  s.version     = Mongoid::Gitifield::VERSION
  s.date        = '2017-09-30'
  s.summary     = 'Version control on Mongoid document with GIT'
  s.description = 'Mongoid-gitifield provides version control on your mongoid document field with git (the real git), gitify your field. Facilitating features from git to keep track on your changes, diff from versions and ability to update the value by applying patch.'
  s.authors     = ['Philip Yu']
  s.email       = 'ht.yu@me.com'
  s.files       = `git ls-files`.split('\n')
  s.require_paths = ['lib']
  s.add_dependency 'git'
end
