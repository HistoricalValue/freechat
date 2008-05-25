module Isi
  module FreeChat
    module Protocol
      module Bitch
        # This is the superclass of all message handlers. Message handlers
        # are notified about speciific (or all) types of messages and deal
        # with them and their consequencies.
        class MessageHandler
          def mtypes 
            raise "Unimplemented #{self.class}#mtypes() method"
          end
          
          attr_reader :bitch
          alias_method :message_types, :mtypes
          
          # Sets the bitch. Can be done only once. Returns true if the bitch
          # is set as a result of this method invokation, false otherwise.
          def bitch= b
            if @bitch then false else @bitch = b; true end
          end
          
          # Returns the +MessageCentre+ given by +bitch+.
          def mc
            bitch.mc
          end
          alias_method :message_centre, :mc
          # Returns the +Linker+ given by +bitch+.
          def link
            bitch.link
          end
          alias_method :linker, :link
          
          # Default method which is called when a new message is received.
          # Default implementation (this) simply raises an error.
          # * addr : is the addr from which the message was received.
          # * msg : is the message that was received.
          def message_received addr, msg
            raise 'Unimplemented MessageHandler#message_received() method'
          end
        end
      end
    end
  end
end
