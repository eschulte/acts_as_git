require 'active_file'
require 'git'
require 'acts_as_git'
require 'git_extensions'
ActiveFile::Base.send(:include, ActiveFile::Acts::GitControlled)
