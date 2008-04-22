module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        # Message is the base class of all messages.
        #
        # The common functionality among messages is very limited and basic
        # and it consists essentially of accessors to the following properties:
        # * MID  : the message ID (spatially and temporally unique)
        # * args : arguments of the message, given as pairs of arg key => value
        class Message
          Isi::db_hello __FILE__, name
          
          ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last

          # Initialises this message with the given ID (which must be unique
          # in space and time) and the given args. 
          # 
          # MID can be anything as long as it implements sensibly the
          # == method.
          #
          # args should be a +Hash+ with the arguments of this message. The
          # hash will not be duplicated so changes on it after it has been given
          # as a message argument holder better be absolutely conscious.
          def initialize mid, args
            @mid = mid
            @args = args
          end

          attr_reader :mid, :args
          
          # Returns the value of the arg with the given name.
          #
          # Equivalent to calling +args+[arg_name]
          def [] arg_name
            args[arg_name]
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
