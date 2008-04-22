# encoding: ascii-8bit

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
        # * type : the message type, as managed by the Message Centre
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
          # +==+ method.
          #
          # args should be a +Hash+ with the arguments of this message. The
          # hash will not be duplicated so changes on it after it has been given
          # as a message argument holder better be absolutely conscious.
          # 
          # Type is something that is managed by the Message Centre.
          def initialize mid, args, type
            @mid = mid
            @args = args
            @type = type
          end

          attr_reader :mid, :args, :type
          
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
          # * type: The type's length (up to 4294967295) and the type are
          #         written
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
            case
            when type.is_a?(String)  then type_str = true
            when type.is_a?(Integer) then type_str = false
            else raise UnserialisableMessageException.new('Type')
            end
            for arg_name, arg in args do
              raise UnserialisableMessageException.new('Argument name:' + arg_name) if
                  !(arg_name.is_a?(String) || arg_name.is_a?(Integer))
              raise UnserialisableMessageException.new('Argument value:' + arg) if
                  !(arg.is_a?(String) || arg.is_a?(Integer))
            end
            
            # We are clean here
            result = ''
            # write type length and type
            stringed = type_str ? type.dup : String::from_bytes(type.bytes)
            stringed.force_encoding result.encoding
            result += get_length stringed
            result += stringed
            # write MID length and MID
            stringed = mid_str ? mid.dup : String::from_bytes(mid.bytes)
            stringed.force_encoding result.encoding
            result += get_length stringed
            result += stringed

            # write args length
            bytes = args.length.bytes
            # pad
            bytes.length.upto(3) { |index| bytes[index] = 0 }
            result += String::from_bytes bytes
            
            for arg_pair in args do
              for arg_el in arg_pair do
                stringed = arg_el.is_a?(String) ? arg_el.dup :
                    String::from_bytes(arg_el.bytes)
                stringed.force_encoding result.encoding
                result += get_length stringed
                result += stringed
              end
            end

            return result
          end
     
          # call-seq:
          #     deserialise(sdata) -> [type, mid, args]
          
          # Deserialises the data of a string which was produced by the
          # default implementation of +serialise+.
          #
          # Raises +DeserialisationException+ if anything unexpected happens.
          #
          # Returns an array whose all elements are strings created
          # from the binary data:
          #     [type, mid, args_hash]
          def self.deserialise sdata
            case
            when sdata.is_a?(String) then sdata = sdata.bytes.to_a
            when sdata.is_a?(Array) then ;
            else raise DeserialisationException.new("sdata is not a String " \
                "or array: sdata.class = #{sdata.class}")
            end
            # Read type and mid
            type, mid = Array.new(2).map! { read_field sdata }
            
            # Read arguments number
            args_length = (
              len_bytes = sdata[0..3]; sdata[0..3] = []
              Integer::from_bytes len_bytes
            )
            
            args = {}
            # Read argumnents
            args_length.downto(1) { |arg_num|
              arg_name, arg_value = Array.new(2).map! { read_field sdata }
              args[arg_name] = arg_value
            }
            
            [type, mid, args]
          end
          
          private
          # Returns the byte length of the given string.
          # If the length requires more than 4 bytes to be represented
          # (if it is larger than 4294967295), then a +SizeTooLargeException+
          # is thrown.
          def get_length str
            bytes = str.bytesize.bytes
            raise SizeTooLargeException if bytes.length > 4
            # Pad bytes
            bytes.length.upto(3) { |i| bytes[i] = 0 }
            return String::from_bytes(bytes)
          end

          private_class_method
          # Reads a field's length bytes and then the field's value bytes
          # from the given *byte array*(!!!). Nullifies the used bytes
          # in the array. Returns the field's value as a string created from
          # the binary data
          def self.read_field sdata
            len_bytes = sdata[0..3]; sdata[0..3] = []
            length = Integer::from_bytes(len_bytes)
            raise DeserialisationException.new('Length <= 0 read:') \
                if length <= 0
            value_bytes = sdata[0..length-1]; sdata[0..length-1] = []
            String::from_bytes(value_bytes)
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
