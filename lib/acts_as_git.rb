module ActiveFile
  module Acts
    module Git
      require 'git'

      def self.included(base)
        base.extend ActiveFile::Acts::Git::ClassMethods
        # overwrite/wrap some methods
        # this may be a good place to override methods
      end

      module ClassMethods
        # ActiveFile objects which are located at the top of a git
        # repository
        def acts_as_git_repo
          return if self.included_modules.include?(ActiveFile::Acts::Git::RepoInstanceMethods)
          send(:include, ActiveFile::Acts::Git::RepoInstanceMethods)
        end

        # ActiveFile objects which live inside of a git repository
        def acts_as_git
          return if self.included_modules.include?(ActiveFile::Acts::Git::InstanceMethods)
          send(:include, ActiveFile::Acts::Git::InstanceMethods)
        end
      end

      module RepoInstanceMethods
        @git
        def git() @git end
        def git=(git) @git = git end
      end

      ## methods no Git::Base
      #
      # - cat file
      # - checkout_file: checkout an old version of a file
      # - commit(message, opts)
      # - commit_all: like commit but adds all changed stuff first
      # - current_branch
      # - grep: returns an array of hashes and types
      # - remote:
      # - pull:

      module InstanceMethods

        # Return the information on the last commit at which this file
        # was changed.
        def last_commit

        end
        alias :last_update :last_commit

        # Return the time at which this file was last updated
        def last_update_at
        end

        # Return the name of the author of the last update
        #
        # (possibly return the name of the commit'r and the author)
        def last_update_by
        end

        # Return the commit message of the last update
        def last_update_message
        end

      end
    end
  end
end
