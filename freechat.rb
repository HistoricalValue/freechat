# encoding: UTF-8
$isi = Hash[:db_hello, false, :db_bye, false]

require 'pathname'
require 'optparse'
require 'isi/lib'
require 'isi/freechat'
require 'isi/freechatui'

module Main
  Options = Struct::new(:help, :mode, :default_mode_used,
      :config_dir, :message_handlers_config_file, :bbq_config_file,
      :verbose_level, :manual, :colour, :hell, :ip, :default_ip_used,
      :port, :default_port_used, :id, :last_id_used, :no_id)
  class Options
    def initialize(*args)
      super(*args[0..-2])
    end
    def inspect
      "#<struct #{self.class.name} #{ result = []
        each_pair { |name, value|
          result << "#{name}=#{ case name
                                when :mode then
                                  OptionParser::MODE_VALUES.at(value)
                                else value
                                end.inspect}"
        }
        result.join(' ')
      }>"
    end
    alias_method :hell?, :hell
    alias_method :default_mode_used?, :default_mode_used
    alias_method :manual?, :manual
    alias_method :help?, :help
    alias_method :default_ip_used?, :default_ip_used
    alias_method :default_port_used?, :default_port_used
    alias_method :last_id_used?, :last_id_used
  end
  
  class OptionParser
    MODE_FREECHAT = 0x00
    MODE_BBQEDIT  = 0x01
    MODE_VALUES   = %w[ freechat bbqedit ]
    MODE_DEFAULT  = MODE_FREECHAT
    CONFIG_DIR_DEFAULT = File.join(ENV['HOME'], '.config', 'freechat')
    CONFIG_MESSAGE_HANDLERS_DEFAULT = File.join(CONFIG_DIR_DEFAULT,
        'message_handlers.config')
    CONFIG_BBQ_DEFAULT = File.join(CONFIG_DIR_DEFAULT, 'bbq.str')
    VERBOSE_LEVEL_DEFAULT = 0
    IP_DEFAULT = '0.0.0.0'
    PORT_DEFAULT = 64246
    def initialize(nargs = {})
      @options = Options::new(
          false                          , # help
          nil                            , # mode
          false                          , # default_mode_used
          CONFIG_DIR_DEFAULT             , # config_dir
          CONFIG_MESSAGE_HANDLERS_DEFAULT, # message_handlers_config_file
          CONFIG_BBQ_DEFAULT             , # bbq_config_file
          VERBOSE_LEVEL_DEFAULT          , # verbose_level
          false                          , # manual
          false                          , # colour
          false                          , # hell
          nil                            , # ip/interface to bind to
          false                          , # default_ip_used
          nil                            , # port to bind to
          false                          , # default_port_used
          nil                            , # id
          false                          , # last_id_used
          false                          , # no_id
          nil
          )
      @option_parser = ::OptionParser::new { |op|
        op.banner = "#{op.program_name
            } [options]: Start an instance of freechat."

        op.separator ' '
        op.separator 'General options'
        op.on("--mode=MODE", '-m',
            'Select operation mode (' +
                "default=#{MODE_VALUES.at(MODE_DEFAULT)}) {#{
                    MODE_VALUES.join '|'}}", MODE_VALUES) { |mode|
          raise ArgumentError::new('no argument for --mode') unless mode
          raise ArgumentError::new("Invalid mode argument: #{mode}") unless
              (index = MODE_VALUES.index(mode))
          @options.mode = index
        }
        op.on('--ip=IP', 'IP/Local interface to bind to ' +
            "(default=#{IP_DEFAULT})") { |ip|
          @options.ip = ip
        }
        op.on('--port=port', 'Port to bind to '+"(default=#{PORT_DEFAULT})"
            ) { |port|
          @options.port = port
        }
        op.on('--id=ID', 'Self id (default=[last id used successfully)'
            ) { |id|
          @options.id = id
        }
        op.on('--[no-]colour', 'Switch colours on or off') { |colour|
          @options.colour = colour
        }
        op.on('--config-dir=DIR', 'Specify the root dir of config files ' +
            "(default=#{CONFIG_DIR_DEFAULT})") { |config_dir|
          @options.config_dir = config_dir
        }
        op.on('--[no-]help', '-h', 'Show this help message and exit') { |h|
          @options.help = h
        }
        op.on('--[no-]manual', 'Show a complete manual and exit') { |m|
          @options.manual = m
        }
        op.on('--verbose=[LEVEL]', '-v', 'Set verbosity level',
            Integer) { |v|
          @options.verbose_level = if v then v else 1 end
        }

        op.separator ' '
        op.separator 'Options for fine tuning of configuration files'
        op.on('--config-mh=PATH',
            'Specify the message handlers config file ' +
            "(default=#{CONFIG_MESSAGE_HANDLERS_DEFAULT})") { |mhcf|
          @options.message_handlers_config_file = mhcf
        }
        op.on('--config-bbq=PATH', 'Specify the buddy book config file ' +
            "(default=#{CONFIG_BBQ_DEFAULT})") { |bbq|
          @options.bbq_config_file = bbq
        }

        op.separator ' '
        op.separator ' '
        op.on('--hell') {
          @options.hell = true
        }
      }
    end # OptionParser#initialize()
    def parse(argv = %w[ ])
      remainder_args = @option_parser.parse(argv)
      parse_remainder_args(remainder_args)
      analyse_options # logically check given options or their absense,
                      # extract information from them and update their
                      # values.
      @options
    end # OptionParser#parse()
    def to_s
      @option_parser.to_s
    end # OptionParser#to_s()
    private
    def parse_remainder_args(r_args)
    end # - OptionParser#parse_remainder_args()
    def analyse_options
      # if no mode, assign default
      unless @options.mode
        @options.mode = MODE_DEFAULT
        @options.default_mode_used = true
      end
      # if no ip bind address specified, assign default
      unless @options.ip
        @options.ip = IP_DEFAULT
        @options.default_ip_used = true
      end
      # if no bind port is specified, assign default
      unless @options.port
        @options.port = PORT_DEFAULT
        @options.default_port_used = true
      end
      # transform all paths to Pathnames
      for member in [:config_dir, :message_handlers_config_file,
          :bbq_config_file] do
        @options[member] = Pathname(@options[member])
      end
      # if no id is given, try to load last successfully used
      unless @options.id
        last_id_pathname = @options.config_dir + 'last_id'
        if last_id_pathname.exist? then
          @options.id = last_id_pathname.read.strip!
          @options.last_id_used = true
        else 
          @options.no_id = true
        end
      end
    end # - OptionParser#check_options()
  end # class Main::OptionParser

  class UI
  end # class Main::UI

  def stardabitch # tough job
    
  end # Main::startbitch()

  class Hell_t < Exception
    def initialize(msg = nil)
      super(msg ||
          'Probably the command line arguments make so little sense ' +
          'that the program reached this completely out-of-mind state. ' +
          'It\'s like, Shpongled or something. Your mission and you life ' +
          'end here.')
    end
  end
  Hell = Hell_t::new
  def main(args)
    op = OptionParser::new
    @options = opts = op.parse(args)
    if    opts.help?   then
      puts(op) # then exit
    elsif opts.manual? then
      puts "(manual page, char_len=#{Manual.length}, byte_len=#{
          Manual.bytesize}. To view without colours try --no-colour)"
      puts(Manual) # then exit
    elsif opts.no_id
      raise Hell_t::new('No --id given and no successfully used last ' +
          'id found')
    elsif !opts.hell? && # hell level cheat
           opts.mode == OptionParser::MODE_FREECHAT 
           then # noraml operation
      note 'Using default --mode=freechat' if opts.default_mode_used?
      warn "Using default binding interface (IP=#{opts.ip})" \
          if opts.default_ip_used
      warn "Using default binding port (#{opts.port})" \
          if opts.default_port_used
      note "Using last successfully used id: #{opts.id}" \
          if opts.last_id_used
      # Starting the bitch... Tough job
      stardabitch
    elsif !opts.hell? && # hell level cheat
           opts.mode == OptionParser::MODE_BBQEDIT
           then # edit bbq
      puts 'starting edit bbq - coming soon'
    else
      raise Hell
    end
  rescue ::OptionParser::InvalidArgument,
         ::OptionParser::MissingArgument,
         ::OptionParser::InvalidOption   => e
    puts "Argument error: #{e.message}"
  rescue Hell_t => e
    puts "Hell: #{e.message}"
  end # Main#main()

  def note msg
    puts(' - [notice ] ' + msg)
  end # Main#note()
  def warn msg
    puts(' = [warning] ' + msg)
  end # Main#warn()

  ### Terminal decorations and escape sequences
  TE = "\033["; TEe = 'm'
  def self.tesc(control)
    TE + control.to_s + TEe
  end # Main#tesc()
  def self.thl(text) # highlight text
    tesc(1) + text.to_s + tesc(22)
  end
  def self.tudl(text) # underline text
    tesc(4) + text.to_s + tesc(24)
  end
  def self.tgreen(text) # foreground to green
    tesc(32) + text.to_s + tesc(39)
  end
  def self.tblue(text) # foreground to blue
    tesc(34) + text.to_s + tesc(39)
  end
  def self.tyellow(text) # foreground to yellow
    tesc(33) + text.to_s + tesc(39)
  end
  def self.tred(text) # foreground to red
    tesc(31) + text.to_s + tesc(39)
  end
Manual = <<EOS
#{thl tyellow 'General info'}
This is the launcher for the Freechat utility.

This launcher can start two different things:
 #{thl tgreen '*'} the freechat client
 #{thl tgreen '*'} a buddy book editor

#{thl tblue '/----------------------------------------------------------------------------\\'}
#{thl tblue '|'} The #{thl 'freechat client'} is the normal operation mode. It is a client           #{thl tblue '|'}
#{thl tblue '|'} which provides a command line interface to the freechat protocol, which is #{thl tblue '|'}
#{thl tblue '|'} running under the interface. A complete manual of usage if available at    #{thl tblue '|'}
#{thl tblue '|'} run-time through the command line interface. To access the basic help, one  #{thl tblue '|'}
#{thl tblue '|'} can give the command "#{thl '/help'}" as soon as the interface is started.          #{thl tblue '|'}
#{thl tblue '\----------------------------------------------------------------------------/'}

#{thl tblue '/----------------------------------------------------------------------------\\'}
#{thl tblue '|'} The #{thl 'buddybook editor'} is a simple command line interface to manage          #{thl tblue '|'}
#{thl tblue '|'} the entries of the buddybook. A complete manual of usage is available for  #{thl tblue '|'}
#{thl tblue '|'} the #{thl 'buddybook editor'} at run-time as well.                                   #{thl tblue '|'}
#{thl tblue '\----------------------------------------------------------------------------/'}

#{thl tyellow 'Explanation of command line arguments'}
#{thl tred '-m'}, #{thl tblue '--mode'}=#{tudl '[freechat | bbqedit]'}
      #{thl '-'} Selects operation mode. #{tudl 'MODE'} can be either "#{tudl 'freechat'}" or "#{tudl 'bbqedit'}", or
        any unambiguous initial part of those arguments.
      #{thl '-'} "#{tudl 'freechat'}" will start the freechat client. A complete manual of usage is
        available at run-time throught the freechat command line interface. To
        access the basic help menu one can give the command "#{thl '/help'}" as soon as
        the interface is started.
      #{thl '-'} "#{tudl 'bbqedit'}" will start the buddy book editor. A complete manual of usage
        is available at run-time as well.

   #{thl tblue '--ip'}=#{tudl 'IP'}
      #{thl '-'} Specifies the local #{tudl 'IP'} to bind to. This is used for the port which
        is listening for incoming connections from other clients.
      #{thl '-'} WARNING: If an #{tudl 'IP'} is not specified then the default is #{tudl OptionParser::IP_DEFAULT}#{if OptionParser::IP_DEFAULT == '0.0.0.0' then ', which
        will accept connections from any interface.' else '.' end}

   #{thl tblue '--port'}=#{tudl 'PORT'}
      #{thl '-'} Specifies the #{tudl 'PORT'} to which #{thl 'freechat'} will bind a listening port to
        in order to accept connections from other clients. The default
        port (which will be used if no port is specified) is #{
        tudl OptionParser::PORT_DEFAULT}.

   #{thl tblue '--id'}=#{tudl 'ID'}
      #{thl '-'} Specifies the #{tudl 'ID'} of this client. This is the #{tudl 'ID'} according to which
        this client will be introduced to others when making a connection
        and also the #{tudl 'ID'} according to which other clients will identify this
        one.
      #{thl '-'} The given #{tudl 'ID'} should exist in the existing BuddyBook, despite the
        fact that its #{tudl 'IP'} and #{tudl 'port'} will not be used. Instead of the #{tudl 'IP'} and
        #{tudl 'port'} specified in the buddy book store, the one specified as
        command line arguments (or their default values) will be used
        instead. See #{thl tblue '--ip'}, #{thl tblue '--port'} and #{thl tblue '--config-bbq'}.

   #{thl tblue '--config-dir'}=#{tudl 'DIR'}
      #{thl '-'} Specifies the configuration directory. The default is deduced by the
        value of the #{tudl 'HOME'} environment variable ($HOME/.config/freechat). This
        is the root configuration directory in which are expected to be found
        (under specific sub-directories sometimes) all configuration files. For
        further tuning of configuration files, one can use the #{thl "#{tblue '--config-'}*"}
        arguments.

   #{thl tblue '--config-mh'}=#{tudl 'PATH'}
      #{thl '-'} Specifies the path to the configuration file of the message handlers.
        The default value is deduced from the value of the default
        configuration root directory, #{tudl 'CONFIG_ROOT'} (see #{thl tblue '--config-dir'})
        (CONFIG_ROOT/message_handlers.config).
      #{thl '-'} The message handlers configuration file specifies which message
        hanlders should be loaded and which types of messages are they
        supposed to hanlde. If this makes no sense, one should refer to the
        #{thl 'Freechat Protocol'} documentation.
    #{thl tblue '--config-bbq'}=#{tudl 'PATH'}
      #{thl '-'} Specifies the path to the configuration file which holds the buddy book
        information. The default value is deduced from the value of the
        default configuration directory, #{tudl 'CONFIG_ROOT'} (see #{thl tblue '--config-dir'})
        (CONFIG_ROOT/bbq.str).
      #{thl '-'} The buddy book configuration file (#{tudl 'bbq config'}) stores buddies and
        any associated information required for each buddy as an entry in a
        buddy book entry. If this makes no sense, one should refer to the
        #{thl 'Freechat Protocol'} documentation.
      #{thl '-'} The #{tudl 'bbq config'} is not a simple text file. Or almost not. It has
        entries whose meaning, positioning, quantity, presence, etc are
        strictly defined and required to be in perfect conformance with what
        the freechat engine expects to read. Therefor editing by hand is
        discouraged unless one knows what she is doing. Currently the preferred
        way to edit the #{tudl 'bbq config'} is by invoking the #{tudl 'bbq editor'} (see
        #{thl tblue '--mode'}=#{tudl 'bbqedit'})

   #{thl tblue '--[no-]manual'}
      #{thl '-'} Sets manual mode on or off. On manual mode, this text will be printed
        and the application will exit successfully.
      #{thl '-'} The manual page (as it is
        probably apparent from this text) uses standard ANSI escape sequences
        to colour the terminal text. If one wishes to disable those colours,
        #{thl tblue '--manual'} can be called in conjunction with #{thl tblue '--no-colour'} (see
        #{thl tblue '--[no-]colour'}).

   #{thl tblue '--[no-]colour'}
      #{thl '-'} Sets usage of colours.

#{thl tred '-h'},#{thl tblue '--[no-]help'}
      #{thl '-'} Prints a short descriptions of available commands and exits
        successfully. No colours are used, even if #{thl tblue '--colour'} is used.

#{thl tred '-v'},#{thl tblue '--verbose'}=#{tudl 'LEVEL'}
      #{thl '-'} Sets the verbosity level of the application to level #{tudl 'LEVEL'}. The higher
        the level, the more information is reported. If this option is passed
        with its short form (#{thl tred '-v'}), then #{tudl 'LEVEL'} is considered to be 1. Valid
        #{tudl 'LEVEL'} values are natural numbers from 0 (no verbosity) to any
        higher number (more and more verbosity).
      #{thl '-'} This option is totally useless under normal circumstances. All possible
        information that the use could require is available through the
        interface in some way. This option is mostly used for debugging or
        when something goes wrong and further information is required in order
        to find out what.

   #{thl tblue '--σκατιλίς'}=#{tudl 'το_όνομά_σου'}
      #{thl '-'} Κάνει σάμμον την #{thl 'Σκατιλίς'}, το μαύρο φόρεμά σου. Πετάγονται #{thl 'Δέρεβιρν'}
        από παντού και ξεχειλίζει διάρροια από κάθε πηγή υγρού (πχ. ουρήθρα).
EOS

end # Main

if __FILE__ == $0 then 
  include Main
  main(ARGV)
end


