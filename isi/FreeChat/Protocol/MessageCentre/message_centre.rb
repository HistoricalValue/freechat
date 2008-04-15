module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        class MessageCentre
          Isi::db_hello __FILE__, name

          require 'digest/sha2'
          require 'logger'
          
          ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last

          # Constructs a new message centre.
          #
          # === Arguments
          # * id_seed: used in generating message IDs which are hopefully
          #            spatially and timely unique. It is not used directly
          #            in the ID generation, but it is first digested with
          #            an 512bit SHA2 digester
          def initialize id_seed = ((rand+rand+rand).to_s + DateTime.now.to_s).
            crypt('f6')
            @digester = Digest::SHA2.new 512
            # id_seed is used in generating message IDs which are hopefully
            # spatially and timely unique
            @id_seed = @digester.digest id_seed
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
            @forwarded = {}
            # Stores message delivery failure records. Index is a MID and
            # mapped object is an Array of failure records.
            @failures = {}
            
            # Loggar
            @logger = Logger.new 'message_centre.log'
            @logger.level = Logger::DEBUG
          end
          
          # Forgets all information about _mid_. If mid is recorded as a
          # native message (originating from this MC) pending for delivery,
          # it will be erased from records. If it is a forwarded message,
          # it will also be erased from records.
          def expire mid
            @pending.delete mid
            @forwarded.delete mid
            @failures.delete mid
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
          # [Origin BID, BCG ID]. If it was a native message it will return
          # medium (buddy cloud gate) BID.
          # *The message is not deleted from any records!*
          def failure mid
            @failures[mid] = [] unless @failures[mid]
            case
            when mbid = @pending[mid] then
              @failures[mid] << [TimeDate.now, mbid]
              return mbid
            when origin_bcg = @forwarded[mid] then
              @failures[mid] << [TimeDate.now, mbid]
              return origin_bcg
            else
              # Bad
              @logger.error('failure') {
                "Message which is not recorded in forwarded or pending "\
                "failed:\n"\
                "MID: #{mid}\n"\
                "pending: #{@pending}\n"\
                "forwarded: #{@forwarded}\n"
              }
              return nil
            end
          end
          
          # Sends a message.
          #
          # Uses the linker in order to find the appropriate BCG buddy
          # and the address book in order to find an address for that buddy.
          #
          # This message is considered native (we are sending it), and so it
          # is recorded as "pending" until a successful delivery notification
          # arrives. When this happens, the message centre can be notified
          # by +success+, in which case the message is removed from all records
          # (expired).
          #
          # If the message fails, +failure+ can be called for further actions.
          # Read +failure+ for more info.
          #
          # === Argument
          # * msg: A message of the appropriate class
          # * register?: if given as false the message will be send but not
          #              recorded in any records. Effectively, any subsequent
          #              calls to +success+ of +fails+ for this message will be
          #              meaningless (and erroneous).
          def send_message msg, register = true
            # TODO implement
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
