require 'active_file'
require 'git'
require 'acts_as_git'
ActiveFile::Base.send(:include, ActiveFile::Acts::GitControlled)
