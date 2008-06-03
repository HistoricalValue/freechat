module Isi
  module FreeChatUI
    Isi::db_hello __FILE__, name
    
    require 'isi/freechat'
    require 'abbrev'
    
    # An UI for freechat that runs completely in console.
    # It does not use any special libraries, such an n-curses.
    #
    # The default command prefix is '/'. To get a list of available commands,
    # type /help .
    module ConsoleUI
      ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
      include Isi::FreeChat::FreeChatUI,
          Isi::FreeChat::Protocol::MessageCentre::MessageTypes,
          Isi::FreeChat::Protocol::MessageCentre
      require ModuleRootDir + 'command_handlers'
      require ModuleRootDir + 'window'
      require ModuleRootDir + 'system_interpreters'
      
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
      DefaultCommandRegex = /^\/(?<command>\w+|\/)(\s+(?<argument>.*))?$/
      DefaultPrompt = '> '
      # === Lock order:
      # * windows
      # * active_window
      # * silence
      # 
      # === Arguments
      # * :gl : global level
      # * :b, :g, :l, :mc , :po : bitch, generic, linker, message centre, post
      #   office levels
      # * :command_regex : regex to match given commands
      # * :prompt : the prompt
      # * :message_centre : the message_centre (to send messages)
      # * :id : own id
      def initialize nargs={}
        @my_id = nargs[:id]
        @message_centre = nargs[:message_centre]
        raise ArgumentError::new('id is nil') unless @my_id
        if @message_centre then
          raise ArgumentError::new("message_centre is something weird: #{
            @message_centre}") unless @message_centre.class <= MessageCentre
        end
        @message_centre_mutex = Mutex::new
        # windows are buffers of lines. Each window has a unique id.
        #     {window.id => window}
        @windows = {}
        @windows_mutex = Mutex::new
        @windows_giver = method :windows
        # active window ID
        @active_window = nil
        @active_window_mutex = Mutex::new
        @active_window_setter = method :active_window=
        @active_window_giver = method :active_window
        # Silence state
        @silence_sync = Isi::SynchronizedValue::new(true)
        @silence_setter = method :silence=
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
        @system_windows_ids_values = @system_windows_ids.values
        @is_system_window_id = method :system_window_id?
        
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
        
        @prompt = nargs[:prompt] || DefaultPrompt
        @default_command_handler = @@DefaultCommandHandlerClass::new(
            method(:warn_unhandled_command))
        @default_command_handler_returning_lambda =
            lambda { @default_command_handler }
        @default_exception_handler = make_default_exception_handler
        @default_exception_handler.define_singleton_method(:handle) { |e|
          self[e]}
        
        @command_line_handling_lambda = make_command_line_handling_lambda
        @window_poller = make_window_poller
        @ignore_next_line = Isi::SynchronizedValue::new false
        @SIGINT_handler_lambda = make_SIGINT_handler_lambda
        
        # command handlers in something like this
        #     {command_name => command_handler}
        # and it needs synchronisation.
        @command_handlers = {}
        # Used both for @command_handlers and @commands_abbrevs
        @commands_mutex = Mutex::new
        # Initialise default command handlers and aliases/abbreviations
        # @command_handlers , @commands_abbrevs
        install_default_command_handlers
        
        # System interpreters are added later by assignment-methods.
        # @system_interpreters -> {system_window_id => interpreter}
        @system_interpreters = {}
        @system_interpreters_mutex = Mutex::new
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
        # Window poller checks for unread lines in windows and prints them
        # if there is no silence
        Thread::new(&@window_poller)
      end
      
      def exit?
        @exit.value
      end
      
      # command handlers are objects which handle a given command. They 
      # must respond to handles?(comm), handle(comm) and command_name.
      # command_name is used to calculate the set of unique abbreviations which
      # can be used as shortbuts instead of complete command names.
      # _comm_ is a command
      # object which has two reader methods: +name+ and +args+. Name returns
      # the name of the command and args an array of the arguments for the
      # command, in the order they were given.
      def add_command_handler command_handler
        @commands_mutex.synchronize {
          @command_handlers[command_handler.command_name] = command_handler
          @commands_abbrevs = @command_handlers.keys.abbrev
        }
      end
      
      def silence?
        @silence_sync.value
      end
      
      def silence= new_value
        @silence_sync.value = new_value
        notify_silence_changed(new_value)
        new_value
      end
      
      def active_window= aw
        @active_window_mutex.synchronize {
          @active_window = aw
        }
        notify_active_window_changed
        aw
      end
      
      def active_window(&block)
        @active_window_mutex.synchronize { block[@active_window] }
      end
      
      def windows(&block)
        @windows_mutex.synchronize { block[@windows] }
      end
      
      def system_window_id?(id)
        @system_windows_ids_values.include?(id)
      end
      
      def bitch_interpreter=(interpreter)
        @system_interpreters_mutex.synchronize {
          @system_interpreters[@system_windows_ids.b] = interpreter
        }
      end
      
      #     bitch_interpreter { } -> block result
      # Calls thread safely the given block and passes the system interpreter
      # as an argument.
      def bitch_interpreter(&block)
        @system_interpreters_mutex.syncrhonize {
          block[@system_interpreters[@system_windows_ids.b]]
        }
      end
      
      def message_centre=(mc)
        raise ArgumentError::new("message_centre is something weird: #{
            mc}") unless mc.class <= MessageCentre
        @message_centre_mutex.synchronize { @message_centre = mc }
      end
      
      #     message_centre { } -> block result
      # Calls thread safely the given block and passes the message centre
      # as an argument.
      def message_centre(&block) 
        @message_centre_mutex.synchronize { block[@message_centre] }
      end
      
      private ##################################################################
      def handle_system_message_from who, level, msg
        if level < @private_levels[who] then
          windows { |windows|
            windows[@system_windows_ids[who]] << msg
          }
        end
      end
      
      Command = Struct::new(:name, :args)
      def command?(line)
        @command_regex.match line
      end
      
      def extract_command(match_data)
        Command::new(match_data[:command],
          if argument = match_data[:argument] then argument.split(' ')
                                              else []
          end)
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
        ch = nil
        @commands_mutex.synchronize {
          ch = @command_handlers[@commands_abbrevs[comm.name]]
        }
        ch = @default_command_handler_returning_lambda.call unless ch
        ch.handle(comm)
      end
      
      def show_prompt
        print @prompt
        STDOUT.flush
      end
      
      def make_command_line_handling_lambda
        lambda { begin
          until self.exit?
            if silence?
              show_prompt
              command_line = STDIN.gets; command_line.chomp!
              if @ignore_next_line.value then
                @ignore_next_line.value = false
                next
              end
              case
              when command_line.nil? then @exit.value = true
              when match_data = command?(command_line) then
                dispatch_command(extract_command(match_data))
              else # it is a message to someone. God?
                new_message(command_line)
              end
              break if @exit.value
            else
              sleep Rational(1,10) # sleep for a while
            end # silence?
          end
        rescue Exception => e
          @default_exception_handler.call(e)
        end}
      end
      
      def install_signal_handlers
        Signal::trap('INT', @SIGINT_handler_lambda)
      end
      
      def make_SIGINT_handler_lambda
        lambda { |*args| begin
          if silence? then 
            puts '' ; show_prompt ; puts '' ; show_prompt
            puts '', 'Next input line will be ignored (just hit return)'
            @ignore_next_line.value = true
          else # no silans
            # back in silans mode
            self.silence = true
          end
        rescue Exception => e then @default_exception_handler.call(e)
        end}
      end
      
      def make_default_exception_handler
        lambda { |e|
          if e then STDERR.puts e.inspect
                    if bktrc = e.backtrace then STDERR.puts bktrc.join("\n")
                    end
                    # also show to user in a pretty way if we are in
                    # silence
                    if silence?
                      puts "! #{e.message}"
                    end
          end
        }
      end
      
      def install_default_command_handlers
        @commands_mutex.synchronize {
          for ch in [
            CommandHandlers::ExitHandler::new(@exit),
            CommandHandlers::HelpHandler::new,
            CommandHandlers::ListHandler::new(@windows_giver, @active_window_giver),
            CommandHandlers::WindowHandler::new(@windows_giver, @active_window_setter),
            CommandHandlers::SpeakHandler::new(@silence_setter),
            CommandHandlers::CloseHandler::new(@windows_giver, @active_window_giver, @is_system_window_id)
          ] ; @command_handlers[ch.command_name] = ch end
          @commands_abbrevs = @command_handlers.keys.abbrev
        }
      end
      
      # notifies everyone to be notified about the active window being changed
      def notify_active_window_changed
        # only self
        active_window_changed
      end
      
      # Take action when the active window changes
      def active_window_changed
        # Do nothing, lines will be shown by poller
      end
      
      def show_unread_lines(*args)
        args.each { |arg|
          case
          when arg.is_a?(String) then puts "* #{arg}"
          when arg.is_a?(Array) then show_unread_lines(*arg)
          end
        }
      end
      
      def notify_silence_changed(silence)
        # only self
        silence_changed(silence)
      end
      
      def silence_changed(silence)
        # Nothing, things find out about silence by #silence?
      end
      
      def make_window_poller
        lambda { begin
          until self.exit?
            unless silence?
              aw = \
                windows { |windows|
                  active_window { |active_window|
                    windows[active_window]
                  }
                }
              if aw then show_unread_lines(aw.read_lines)
                    else puts '! No active window, going back to silence',
                              '/silence'
                         self.silence=true
              end
            end
            sleep 1
          end
        rescue Exception => e then @default_exception_handler.handle(e) end}
      end
      
      def new_message(message)
        # is there an active window?
        active_window = active_window { |aw| aw }
        if active_window.nil? then
          puts '! No active window, message send to the NoWhereMist'
        elsif system_window_id?(active_window)
          @system_interpreters_mutex.synchronize {
            if interpreter = @system_interpreters[active_window] then
              response = interpreter.new_message(message)
              show_system_response(response)
            end
          }
        elsif not message =~ /^$/ #no spam: empty lines ignored (but no spacey lines)
          rcp_bid = windows { |windows| windows[active_window].to_bid }
          message_centre { |mc|
            if mc then
              mc.send_message(
                  mc.create_message(
                      STM_MESSAGE, FRM => @my_id, RCP => rcp_bid, CNT => message
                  )
              )
            else
              puts '! Cannot send message because message centre has not been set'
            end
          }
        end
      end
      
      def show_system_response(*args)
        for arg in args do
          klass = arg.class
          case
          when klass <= Array then show_system_response(*arg)
          when klass <= String then puts ". #{arg}"
          else
            puts "! unknown response from system: #{arg.inspect}"
          end
        end
      end
      
    end
    Isi::db_bye __FILE__, name
  end
end
