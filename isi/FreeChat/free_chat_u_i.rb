module Isi
  module FreeChat
    Isi::db_hello __FILE__, name
    
    # This is the minimal methods an UI for the FreeChat application
    # has to provide.
    # 
    # All the methods in this class simply print everything to STDOUT.
    # Essentially, all methods should be overriden.
    #
    # Each method is specified according to the component a message can arrive
    # from. The methods accept two arguments, one is the level of the message
    # (how serious it is or what type of message it is) and the other is
    # the message itself.
    # 
    # The _level_ argument will be one of the constants defined in this class
    # but no check is performed in the default methods about the type of the
    # level.
    #
    # There is also another generic method, called "generic message" which is
    # intented for messages not arriving from the predefined componenets. It
    # gets an extra argument which is the origin of the message.
    class FreeChatUI
      FATAL  = 0x00
      ERROR  = 0x01
      WARNING= 0x04
      INFO   = 0x08
      DEBUG  = 0x10
      FINE   = 0x20
      FINER  = 0x40
      FINEST = 0x80
      
      def generic_message from, level, msg
        default_print_message_from '?_' + from, level, msg
      end
      alias_method :g, :generic_message
      
      def linker_message level, msg
        default_print_message_from 'Linker', level, msg
      end
      alias_method :l, :linker_message
      
      def post_office_message level, msg
        default_print_message_from 'PostOffice', level, msg
      end
      alias_method :po, :post_office_message
      
      def message_centre_message level, msg
        default_print_message_from 'MessageCentre', level, msg
      end
      alias_method :mc, :message_centre_message
      
      def bitch_message level, msg
        default_print_message_from 'Bitch', level, msg
      end
      alias_method :b, :bitch_message
      
      # This is the method that is called by all default message methods.
      def default_print_message_from from, level, msg
        puts "<#{from}:#{level}> #{msg}"
      end
    end
    
    Isi::db_bye __FILE__, name
  end
end
