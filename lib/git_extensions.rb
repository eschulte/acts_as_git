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
    def graph(starting_point = false)
      if starting_point
        command('log', ["--graph", "#{starting_point}..HEAD"])
      else
        command('log', ['--graph'])
      end
    end
  end
end
