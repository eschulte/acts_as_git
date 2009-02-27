module Git
  class Diff
    # return self.path converted to html with each line wrapped in a
    # span tag, whose class indicates the type of line.  This can be
    # useful for coloring div output with css similar to the
    # following...
    #
    #   div.body pre {
    #   background-color: #fbfbfb;
    #   }
    # 
    #   div.body span.plain-line {
    #   color: #aaaaaa;
    #   }
    # 
    #   div.body span.plus-line {
    #   background-color: #f2fff1;
    #   }
    # 
    #   div.body span.minus-line {
    #   background-color: #fff4f6;
    #   }
    # 
    #   div.body span.plus-file-line {
    #   background-color: #d4ffd1;
    #   }
    # 
    #   div.body span.minus-file-line {
    #   background-color: #ffe7ec;
    #   }
    #
    def html_patch
      self.patch.split("\n").map do |line|
        if line.match("^\\+\\+\\+")
          "<span class=\"plus-file-line\">#{line}</span>"
        elsif line.match("^---")
          "<span class=\"minus-file-line\">#{line}</span>"
        elsif line.match("^\\+")
          "<span class=\"plus-line\">#{line}</span>"
        elsif line.match("^-")
          "<span class=\"minus-line\">#{line}</span>"
        else
          "<span class=\"plain-line\">#{line}</span>"
        end
      end.join("\n")
    end
  end
  
  class Lib
    # calls git log with the --graph option
    def graph(options = {})
      command('log', ["--graph",
                      (options[:pretty] ? "--pretty=#{options[:pretty]}"  : nil),
                      options[:ref]].compact)
    end

    # Return the untracked files in the current git repo.
    def untracked
      status = run_command('git status').split("\n")
      if index = status.index('# Untracked files:')
        untracked = []
        status[index..-1].each do |line|
          untracked << $1 if line =~ /^#\t(.*)$/
        end
        untracked
      end
    end
  end
  
  class Base
    
    @gitignored = nil
    
    def init_ignored
      @gitignored ||= File.read(File.join((self.dir.path), ".gitignore")).map{ |l| l.chomp }
    end
    
    # uses the values of .gitignore to decide whether the given
    # rel_path (path relative to the base of the git directory)
    # matches the .gitignore file
    def ignore?(rel_path)
      init_ignored
      if @gitignored.map{|glob| true if File.fnmatch?(glob, rel_path)}.compact.size > 0
        true
      end
    end
    alias :ignored? :ignore?

    def untracked() self.lib.untracked end
    
  end
end
