module ActiveFile
  module Acts
    module GitControlled
      require 'git'

      def self.included(base)
        base.extend ActiveFile::Acts::GitControlled::ClassMethods
      end

      module ClassMethods
        # ActiveFile objects which live inside of a git repository
        def acts_as_git
          return if self.included_modules.include?(ActiveFile::Acts::GitControlled::InstanceMethods)
          send(:include, ActiveFile::Acts::GitControlled::InstanceMethods)
        end
      end

      ## methods on Git::Base
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
        @git
        def git()
          initialize_git unless @git
          @git
        end
        def git=(git) @git = git end
        
        def initialize_git
          # set @git to the git repo for self
          if self.class.directory?
            @git = Git.init(self.full_path)
          else
            # find the containing repo for an element
            
          end
        end
        
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
        
        # pass missing methods on through to Git
        def method_missing(id, *args)
          if self.git and @git.respond_to?(id)
            if args.size > 0
              @git.send(id, args)
            else
              @git.send(id)
            end
          else
            super(id, args)
          end
        end
        
      end
    end
  end
end
