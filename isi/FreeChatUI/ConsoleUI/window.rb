module Isi
  module FreeChatUI
    module ConsoleUI
      
      # Instaces accessible only through factory method(s)
      class Window
        Isi::db_hello __FILE__, name
        
        @@last_id = 0
        def initialize id, buf_size, title=''
          raise ArgumentError::new('Window id is nil') unless id
          @id = id
          @lines = []
          @title = title
          @buf_size = buf_size
          @cursor = 0 # points to the first unread line
        end
        attr_reader :id, :title
        attr_accessor :buf_size
        
        def each_line(&block)
          @lines.each(&block)
        end
        alias_method :each, :each_line
        
        def << line
          if line.is_a?(String) then
            @lines << line
            while length >= @buf_size do
              @lines.shift
              @cursor -= 1
            end
            @cursor = 0 if @cursor < 0
            true
          else
            false
          end
        end
        alias_method :append_line, :'<<'
        
        def length
          @lines.length
        end
        
        # Returns true if there are unread lines in this window
        def unread?
          length > @cursor
        end
        # Return the number of unrea lines
        def unread
          length - @cursor
        end
        
        # Will invoke +[]+ on the underlying array of lines. Nothing is marked
        # as read.
        def [](*args, &block)
          @lines.[](*args, &block)
        end
        
        #     read_lines(n) -> [line(k), line(k+1), ... , line(k+n-1)]
        # Returns an array of the newer _n_ lines and marks them as read.
        # If _n_ is nil then all unread lines are returned and marked as read.
        # If _n_ is greater than the number of unread lines currently, then
        # some the extra lines are taken from the older lines, right before
        # the new, unread ones. All the new lines will be marked as read.
        # If _n_ is greater than +buf_size+ then an +ArgumentError+ is raised,
        # just for fun.
        # If optional argument _bigmac_ does not evaluate to _false_, then
        # +read_lines+ will return (and mark as read accordingly) whichever
        # is more: the actual unread lines or _n_ lines.
        def read_lines n=nil, bigmac=false
          unlines = unread
          if n.nil? || bigmac && unlines > n then n = unlines end
          raise ArgumentError::new("n>buf_size (#{n}>#{buf_size}). Told you") \
              if n > buf_size
          result = []
          if n > unlines then
            padding = n - unlines
            n = unlines
            result.concat(self[@cursor - padding .. @cursor - 1])
          end
          new_cursor = @cursor + n
          result.concat(self[@cursor .. new_cursor])
          @cursor = new_cursor
          result
        end
        
        # instances accessible only through factory methods
        private_class_method :new
        def self.create title='(untitled)', buf_size=1<<14
          raise ArgumentError::new("buf_size(#{buf_size.inspect
              }) must be an Integer") unless buf_size.is_a?(Integer)
          @@last_id += 1
          new(@@last_id, buf_size, title)
        end
        
        private ################################################################
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
