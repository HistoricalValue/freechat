module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        class MessageCentre
          Isi::db_hello __FILE__, name

          ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last

          def initialize
            # Stores pairs of MID-BID, where BID is the medium buddy.
            # Message whose MIDs are stored here are considered pending
            # until a delivery report for them arrives. *ONLY* messages
            # send by _us_ are stored in this structured. Forwarded messages
            # are recorded in @forwarded.
            @pending = {}
            # Stores information for messages that have been forwarded through
            # this MC. Information is stored as follows:
            # @forwarded[MID] = [Origin BID, BuddyCloudGateID] where:
            # * Origin BID: the buddy from which this message arrived
            # * MID: the message id
            # * BuddyCloudGateID: the buddy through which it is forwarded
            @forwared = {}
          end
          
          # Forgets all information about _mid_. If mid is recorded as a
          # native message (originating from this MC) pending for delivery,
          # it will be erased from records. If it is a forwarded message,
          # it will also be erased from records.
          def expire mid
            @pending.delete mid
            @forwared.delete mid
          end

          # Notifies the message centre that message with _mid_ has been
          # successfully delivered to destination. Message centre will
          # erase it from records, *wether* it was a native message or a
          # forwarded message.
          def success mid
            expire mid
          end
          
          # Message centre will mark that this message failed to be delivered.
          # If this was a forwarded message it will return an array containing
          # [Origin BID, BCG ID]. If it was a native message it will return nil.
          # *The message is not deleted from any records!*
          def failure mid
            # TODO continue
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
