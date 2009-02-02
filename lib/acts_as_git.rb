module ActiveFile
  module Acts
    module GitControlled
      require 'git'

      def self.included(base)
        base.extend ActiveFile::Acts::GitControlled::ClassMethods
        base.send(:after_write, :initialize_new_repo)
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
            until @git
              @git = Git.init(dir)
              dir = File.join(dir, "..")
            end
            @git
          end
        end
        
        def initialize_new_repo
          return self.git unless self.class.directory?
          root = self.full_path
          # create .gitignore
          File.open(File.join(root, ".gitignore"), "w") do |file|
            self.class.git_ignore.each do |to_ignore|
              file << to_ignore+"\n"
            end
          end
          # initialize
          @git = Git.init(self.full_path)
          @git.add
          @git.commit("initial commit")
          @git
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
          self.commit_history.first
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
        
        ## path stuff
        
        # return the path to the root of the git directory
        def git_root
          self.git.dir.path
        end
        
        # return the path to self inside of the containing git
        # directory (see git_root)
        def rel_path
          rel_path = false
          base_path = self.full_path
          root_path = self.git_root
          until root_path == base_path
            path_arr = File.split(base_path)
            rel_path = rel_path ? File.join(rel_path, path_arr.last) : path_arr.last
            base_path = path_arr.first
          end
          rel_path
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
