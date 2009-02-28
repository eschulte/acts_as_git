require 'active_file'
require File.join(File.dirname(__FILE__), 'ruby-git', 'lib', 'git')
require File.join(File.dirname(__FILE__), 'lib', 'acts_as_git')
require File.join(File.dirname(__FILE__), 'lib', 'git_extensions')
ActiveFile::Base.send(:include, ActiveFile::Acts::GitControlled)
