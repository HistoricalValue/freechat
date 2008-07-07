$isi = Hash[:db_hello, false, :db_bye, false]

require 'pathname'
require 'optparse'

module Main
  Options = Struct::new(:help, :mode, :default_mode_used,
      :config_dir, :message_handlers_config_file, :bbq_config_file,
      :verbose_level, :manual)
  class Options
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
    def initialize(nargs = {})
      @options = Options::new(
          false, # help
          nil,   # mode
          false, # default_mode_used
          CONFIG_DIR_DEFAULT, # config_dir
          CONFIG_MESSAGE_HANDLERS_DEFAULT, # message_handlers_config_file
          CONFIG_BBQ_DEFAULT, # bbq_config_file
          VERBOSE_LEVEL_DEFAULT, # verbose_level
          false # manual
          )
      @option_parser = ::OptionParser::new { |op|
        op.banner = "#{op.program_name
            } [options]: Start an instance of freechat."

        op.separator ' '
        op.separator 'General options'
        op.on("--mode=MODE", '-m',
            'Select operation mode (' +
                "default=#{MODE_VALUES.at(MODE_DEFAULT)})",
            "{#{MODE_VALUES.join '|'}}", MODE_VALUES) { |mode|
          raise ArgumentError::new('no argument for --mode') unless mode
          raise ArgumentError::new("Invalid mode argument: #{mode}") unless
              (index = MODE_VALUES.index(mode))
          @options.mode = index
        }
        op.on('--config-dir=DIR', 'Specify the root dir of config files',
            "(default=#{CONFIG_DIR_DEFAULT})") { |config_dir|
          @options.config_dir = config_dir
        }
        op.on('--[no-]help', '-h', 'Show this help message and exit') { |h|
          @options.help = h
        }
        op.on('--[no-]manual', 'Show a complete manual and exit') { |m|
          @options.manual = m
        }
        op.on('--verbose=[LEVEL]', '-v', 'Set verbosity level', Integer) { |v|
          @options.verbose_level = if v then v else 1 end
        }

        op.separator ' '
        op.separator 'Options for fine tuning of configuration files'
        op.on('--config-mh=PATH',
            'Specify the message handlers config file',
            "(default=#{CONFIG_MESSAGE_HANDLERS_DEFAULT})") { |mhcf|
          @options.message_handlers_config_file = mhcf
        }
        op.on('--config-bbq=PATH', 'Specify the buddy book config file',
            "(default=#{CONFIG_BBQ_DEFAULT})") { |bbq|
          @options.bbq_config_file = bbq
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
      # transform all paths to Pathnames
      for member in [:config_dir, :message_handlers_config_file,
          :bbq_config_file] do
        @options[member] = Pathname(@options[member])
      end
    end # - OptionParser#check_options()
  end # class Main::OptionParser

  def main(args)
    op = OptionParser::new
    opts = op.parse(args)
    if    opts.help   then puts(op) # then exit
    elsif opts.manual then puts(Manual) # then exit
    elsif opts.default_mode_used then
      warn 'Using default --mode=freechat'
    end
  rescue ArgumentError,
         ::OptionParser::InvalidArgument,
         ::OptionParser::MissingArgument,
         ::OptionParser::InvalidOption   => e
    puts "Argument error: #{e.message}"
  end # Main#main()

  def warn msg
    puts(' = [warning] ' + msg)
  end # Main#warn()

  ### Terminal decorations and escape sequences
  TE = "\033["; TEe = 'm'
  def self.tesc(control)
    TE + control.to_s + TEe
  end # Main#tesc()
  def self.thl(text) # highlight text
    tesc(1) + text + tesc(22)
  end
  def self.tudl(text) # underline text
    tesc(4) + text + tesc(24)
  end
  def self.tgreen(text) # foreground to green
    tesc(32) + text + tesc(39)
  end
  def self.tblue(text) # foreground to blue
    tesc(34) + text + tesc(39)
  end
  def self.tyellow(text) # foreground to yellow
    tesc(33) + text + tesc(39)
  end
  def self.tred(text) # foreground to red
    tesc(31) + text + tesc(39)
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
#{thl tblue '|'} runtime through the command line interface. To access the basic help, one  #{thl tblue '|'}
#{thl tblue '|'} can give the command "#{thl '/help'}" as soon as the interface is started.          #{thl tblue '|'}
#{thl tblue '\----------------------------------------------------------------------------/'}

#{thl tblue '/----------------------------------------------------------------------------\\'}
#{thl tblue '|'} The #{thl 'buddybook editor'} is a simple command line interface to manage          #{thl tblue '|'}
#{thl tblue '|'} the entries of the buddybook. A complete manual of usage is available for  #{thl tblue '|'}
#{thl tblue '|'} the #{thl 'buddybook editor'} at runtime as well.                                   #{thl tblue '|'}
#{thl tblue '\----------------------------------------------------------------------------/'}

#{thl tyellow 'Explanation of command line arguments'}
#{thl tred '-m'}, #{thl tblue '--mode'}=#{tudl '[freechat | bbqedit]'}
      #{thl '-'} Selects operation mode. #{tudl 'MODE'} can be either "#{tudl 'freechat'}" or "#{tudl 'bbqedit'}", or
        any unambiguous initial part of those arguments.
      #{thl '-'} "#{tudl 'freechat'}" will start the freechat client. A complete manual of usage is
        available at runtime throught the freechat command line interface. To
        access the basic help menu one can give the command "#{thl '/help'}" as soon as
        the interface is started.
      #{thl '-'} "#{tudl 'bbqedit'}" will start the buddy book editor. A complete manual of usage
        is available at runtime as well.

   #{thl tblue '--config-dir'}=#{tudl 'DIR'}
      - Specifies the configuration directory. The default is deduced by the
        value of the #{tudl 'HOME'} environment variable ($HOME/.config/freechat). This
        is the root configuration directory in which are expected to be found
        (under specific subdirectories sometimes) all configuration files. For
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
EOS

end # Main

if __FILE__ == $0 then 
  include Main
  main(ARGV)
end

