require 'active_file'
require File.join(File.dirname(__FILE__), 'ruby-git', 'lib', 'git')
require 'acts_as_git'
require 'git_extensions'
ActiveFile::Base.send(:include, ActiveFile::Acts::GitControlled)
