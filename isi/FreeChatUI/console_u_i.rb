module Isi
  module FreeChatUI
    Isi::db_hello __FILE__, name
    
    require 'isi/freechat'
    
    # An UI for freechat that runs completely in console.
    # It does not use any special libraries, such an n-curses.
    #
    # The default command prefix is '/'. To get a list of available commands,
    # type /help .
    module ConsoleUI
      ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
      include Isi::FreeChat::FreeChatUI
      require ModuleRootDir + 'command_handlers'
      
      # instances accessible only through factory methods
      class Window
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
        def self.create title='(untitled)'
          @@last_id += 1
          new(@@last_id, title)
        end
        
        private ################################################################
      end
      
      @@DefaultCommandHandlerClass = Class::new {
        def initialize warn_meth
          @warn_meth = warn_meth
        end
        def handle comm
          @warn_meth.call comm
        end
      }
      PrivateLevels = Struct::new(:b, :g, :l, :mc, :po)
      SystemWindowsIDs = Struct::new(:b, :g, :l, :mc, :po)
      DefaultLevel = WARNING
      DefaultCommandRegex = /^\/(?<command>\w+)\s+(?<argument>.*$)/
      DefaultPrompt = '> '
      # === Arguments
      # * :gl : global level
      # * :b, :g, :l, :mc , :po : bitch, generic, linker, message centre, post
      #   office levels
      # * :command_regex : regex to match given commands
      # * :prompt : the prompt
      def initialize nargs
        # windows are buffers of lines. Each window has a unique +WindowID+.
        @windows = {}
        # Create private (system) windows and store their keys
        @system_windows_ids = SystemWindowsIDs::new
        @system_windows_ids.each_pair { |key, val| 
          val = Window::create(
              case key
              when :b then 'Bitch'
              when :g then 'General'
              when :l then 'Linker'
              when :mc then 'Message Centre'
              when :po then 'Post Office'
              end)
          @system_windows_ids[key] = val.id
          @windows[val.id] = val
        }
        @global_level = nargs[:gl] || DefaultLevel
        @level_for = {}
        @private_levels = PrivateLevels::new(
            (nargs[:bitch_level]          or nargs[:b]  or DefaultLevel),
            (nargs[:general_level]        or nargs[:g]  or DefaultLevel),
            (nargs[:linker_level]         or nargs[:l]  or DefaultLevel),
            (nargs[:message_centre_level] or nargs[:mc] or DefaultLevel),
            (nargs[:post_office_level]    or nargs[:po] or DefaultLevel)
            )
            
        # Command prefix
        @command_regex = nargs[:command_regex] || DefaultCommandRegex
        # Threads, mutexes, booleans, interaction stuff
        @exit = Isi::SynchronizedValue::new false
        @windows_sync = Isi::SynchronizedValue::new @windows
        
        # Command handlers is an array
        @command_handlers = Isi::SynchronizedValue::new []
        
        @prompt = nargs[:prompt] || DefaultPrompt
        @default_command_handler = @@DefaultCommandHandlerClass::new(
            method(:warn_unhandled_command))
        @default_command_handler_returning_lambda =
            lambda { @default_command_handler }
        @default_exception_handler = lambda { |e|
          if e then STDERR.puts e.inspect
                    if bktrc = e.backtrace then STDERR.puts bktrc.join("\n")
                    end
          end
        }
        
        @command_line_handling_lambda = make_command_line_handling_lambda
        @ignore_next_line = Isi::SynchronizedValue::new false
        @SIGINT_handler_lambda = make_SIGINT_handler_lambda
        
        # Initialise default command handlers
        install_default_command_handlers
      end
      attr_accessor :global_level
      
      def set_level_for(whom, level)
        @level_for[whom] = level
      end
      
      def get_level_for(whom)
        @level_for[whom]
      end
      
      def bitch_level= v
        @private_levels.b = v
      end
      def bitch_level
        @private_levels.b
      end
      
      def general_level= v
        @private_levels.g = v
      end
      def general_level
        @private_levels.g
      end
      
      def linker_level= v
        @private_levels.l = v
      end
      def linker_level
        @private_levels.l
      end
      
      def message_centre_level= v
        @private_levels.mc = v
      end
      def message_centre_level
        @private_levels.mc
      end
      
      def post_office_level= v
        @private_levels.po = v
      end

      def post_office_level
        @private_levels.po
      end
      
      def bitch_message level, msg
        handle_system_message_from :b, level, msg
      end
      alias_method :b, :bitch_message
      
      def generic_message level, msg
        handle_system_message_from :g, level, msg
      end
      alias_method :g, :generic_message
      
      def linker_message level, msg
        handle_system_message_from :l, level, msg
      end
      alias_method :l, :linker_message
      
      def message_centre_message level, msg
        handle_system_message_from :mc , level, msg
      end
      alias_method :mc, :message_centre_message
      
      def post_office_message level, msg
        handle_system_message_from :po, level, msg
      end
      alias_method :po, :post_office_message
      
      # Starts this UI. This will cause prompts on the console etc.
      def start
        # install signal handlers
        install_signal_handlers
        
        # Serve user command prompt in a different thread
        Thread::new(&@command_line_handling_lambda)
      end
      
      def exit?
        @exit.value
      end
      
      # command handlers are objects which handle a given command. They 
      # must respond to handles?(comm) and handle(comm). _comm_ is a command
      # object which has two reader methods: +name+ and +args+. Name returns
      # the name of the command and args an array of the arguments for the
      # command, in the order they were given.
      def add_command_handler command_handler
        @command_handlers.value << command_handler
      end
      
      private ##################################################################
      def handle_system_message_from who, level, msg
        if level < @private_levels[who] then
          @windows[@private_windows_ids[who]] << msg
        end
      end
      
      Command = Struct::new(:name, :args)
      def command?(line)
        @command_regex.match line
      end
      
      def extract_command(match_data)
        Command::new(match_data[:command], match_data[:argument].split(' '))
      end
      
      def warn_unhandled_command comm
        begin
          raise Exception::new(
            "WARNING: unhandled command: #{comm.name}(#{
            comm.args.join ', '})")
        rescue Exception => e
          @default_exception_handler.call(e)
        end
      end

      def dispatch_command(comm)
        @command_handlers.value.find(@default_command_handler_returning_lambda){ |ch|
          ch.handles? comm
        }.handle comm
      end
      
      def show_prompt
        print @prompt
        STDOUT.flush
      end
      
      def make_command_line_handling_lambda
        lambda { begin
          loop do
            show_prompt
            command_line = STDIN.gets
            if @ignore_next_line.value then
              @ignore_next_line.value = false
              next
            end
            case
            when command_line.nil? then @exit.value = true
            when match_data = command?(command_line) then
              dispatch_command(extract_command(match_data))
            end
            break if @exit.value
          end
        rescue Exception => e
          @default_exception_handler.call(e)
        end}
      end
      
      def install_signal_handlers
        Signal.trap('INT', @SIGINT_handler_lambda)
      end
      
      def make_SIGINT_handler_lambda
        lambda { |*args| begin
          2.times { puts '' ; show_prompt }
          puts '', 'Next input line will be ignored (just hit return)'
          @ignore_next_line.value = true
        rescue Exception => e then @default_exception_handler.call(e)
        end}
      end
      
      def install_default_command_handlers
        add_command_handler(CommandHandlers::ExitHandler::new(@exit))
        add_command_handler(CommandHandlers::HelpHandler::new)
      end
      
    end
    
    Isi::db_bye __FILE__, name
  end
end
