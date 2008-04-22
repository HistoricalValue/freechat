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
        #
        # This class implements generically the methods "serialise" and
        # "deserialise". Those methods assume that all properties mentioned
        # above are or contain only +String+s or integers.
        # 
        # Strings are considered serialised already, since writing and reading
        # from streams happens with string buffers.
        # For integers the methods Integer.bytes and Integer::from_bytes
        # are used.
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
          
          # Returns a string which is the serialised form of this message.
          # 
          # For default serialisation to work, all objects must be strings
          # or Integers. If this is not the case and objects refered by
          # the message need special serialisation methods, subclasses should
          # override this method.
          # 
          # If any of the objects references in the args hash or the MID are
          # not Strings or Integers, a +UnserialisableMessageException+
          # is raised.
          # 
          # Default serialisation takes place as follows:
          # * MID : MID's length (up to 4294967295) is writen as bytes and
          #         the actual MID afterwards
          # * Args: The number of elements is written (up to 4294967295) as
          #         bytes. For each pair in the args hash, the length of the
          #         key (up to 4294967295) is written as bytes and then the
          #         key itself. Then the length of the value (up to 4294967295)
          #         is written as bytes and then the value itself.
          #
          def serialise
            # Make validations about types first
            case
            when mid.is_a?(String)  then mid_str = true
            when mid.is_a?(Integer) then mid_str = false
            else raise UnserialisableMessageException.new('MID')
            end
            for arg_name, arg in args do
              raise UnserialisableMessageException.new('Argument name:' + arg_name) if
                  !(arg_name.is_a?(String) || arg_name.is_a?(Integer))
              raise UnserialisableMessageException.new('Argument value:' + arg) if
                  !(arg.is_a?(String) || arg.is_a?(Integer))
            end
            
            # We are clean here
            # ---
            # write MID length and MID
            stringed = mid_str ? mid : String::from_bytes(mid.bytes)
            result = get_length stringed
            result += stringed

            # write args length
            stringed = String::from_bytes args.length.bytes
            result += get_length stringed
            result += stringed
            
            for arg_pair in args do
              for arg_el in arg_pair do
                stringed = arg_el.is_a?(String) ? arg_el :
                    String::from_bytes(arg_el.bytes)
                result += get_length stringed
                result += stringed
              end
            end
            
            return result
          end
          
          private
          # Returns the byte length of the given string.
          # If the length requires more than 4 bytes to be represented
          # (if it is larger than 4294967295), then a +SizeTooLargeException+
          # is thrown.
          def get_length str
            bytes = str.bytesize.bytes
            raise SizeTooLargeException if bytes.length > 4
            return String::from_bytes(bytes)
          end

          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
