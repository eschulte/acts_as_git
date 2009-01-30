require 'active_file'
require 'git'
ActiveFile::Base.send(:include, ActiveFile::Acts::Git)
