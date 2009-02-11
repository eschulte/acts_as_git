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
        attr_accessor :git_ignore
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
            @git = Git.init(self.full_path) # TODO: maybe change init to open
          else
            # find the containing repo for an element
            # recurse up the directory tree until one is a git repo.
            @git = nil
            dir = File.dirname(self.full_path)
            until File.exist?(File.join(dir, ".git"))
              dir = File.join(dir, "..")
            end
            @git = Git.init(dir)
          end
        end
        
        ## How to display a single file's history
        # 
        # http://www.gelato.unsw.edu.au/archives/git/0605/20453.html
        # 
        # probably with recent enough git, one of
        #
        # git whatchanged A
        # 
	# git log --stat -- A
	# git log -p -- A
	# git log -p --full-diff -- A
        #
        # actually *all* of the git commands can be limited by
        # pathname
        #
        # with Ruby/Git you can limit a Git::Log object to a path, and
        # then view only those commits which affected the path, so...
        #
        # 
        
        def commit_history
          if self.class.directory?
            commit_history_directory
          else
            commit_history_entry
          end
        end
        def commit_history_entry
          self.git.log.path(self.full_path)
        end
        def commit_history_directory
          self.git.log
        end
        alias :history :commit_history
        
        # Return the information on the last commit at which this file
        # was changed.
        def last_commit
          self.commit_history.first rescue nil
        end

        # Return the time at which this file was last commitd
        def last_commit_at
          self.last_commit.date
        end

        # Return the name of the author of the last commit
        #
        # (possibly return the name of the commit'r and the author)
        def last_commit_by
          self.last_commit.author
        end

        # Return the commit message of the last commit
        def last_commit_message
          self.last_commit.message
        end
        
        # return the text of self at the specified revision
        #
        # revisionish can be a revision specification like any of the
        # following...
        #
        # a head specification
        #   HEAD
        #   HEAD~1
        #   HEAD~3
        #
        # a hash sha
        #   05e8468
        def at_revision(revisionish)
          self.cat_file(revisionish+":"+self.rel_path)
        end
        
        # Checkout the version of self at revisionish overwriting the
        # current version of self.  This uses the git checkout command.
        def checkout_at(revisionish)
          self.checkout_file(revisionish, self.rel_path)
        end
        alias :revert :checkout_at
        
        def save_and_commit(message)
          if self.save
            self.stage
            self.commit(message)
          end
        end
        
        def stage
          self.git.add(self.rel_path)
        end
        
        ## path stuff
        
        # return the path to the root of the git directory
        def git_root
          self.git.dir.path
        end
        
        # return the path to self inside of the containing git
        # directory (see git_root)
        def rel_path
          $1 if self.full_path.match(self.git_root+"/?(.*)$")
        end
        
        # pass missing methods on through to Git
        def method_missing(id, *args)
          if self.git and @git.respond_to?(id)
            if args.size > 0
              @git.send(id, *args)
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
