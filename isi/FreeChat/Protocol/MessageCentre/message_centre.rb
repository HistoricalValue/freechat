module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        class MessageCentre
          Isi::db_hello __FILE__, name

          require 'digest/sha2'
          require 'logger'
          require ModuleRootDir + 'message_types'
          include MessageTypes
          
          # Constructs a new message centre.
          #
          # === Arguments
          # * buddybk: buddy book, used to look up addresses
          # * id_seed: used in generating message IDs which are hopefully\
          #            spatially and timely unique. It is not used directly\
          #            in the ID generation, but it is first digested with\
          #            an 512bit SHA2 digester
          def initialize buddybk,
            id_seed = ((rand+rand+rand).to_s + DateTime.now.to_s).crypt('f6')
            @addrbook = buddybk
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
          # * msg      : A message of the appropriate class
          # * register?: if given as false the message will be send but not\
          #              recorded in any records. Effectively, any subsequent\
          #              calls to +success+ of +fails+ for this message will be\
          #              meaningless (and erroneous). +send_message+ and\
          #              +forward_message+ with <code>register?=false</code>\
          #              are equivalent.
          def send_message msg, register = true
            # TODO implement
          end
          
          # Forwards a message.
          #
          # Uses the linker in order to find the appropriate BCG buddy
          # and the address book in order to find an address for that buddy.
          #
          # The message is considered forwarded and therefor is recorded
          # in the forwarded messages record, until a successful delivery
          # notification arrives. When this happens, the message centre can be notified
          # by +success+, in which case the message is removed from all records
          # (expired).
          # 
          # === Argument
          # * msg      : A message of the appropriate class
          # * register?: if given as false the message will be send but not\
          #              recorded in any records. Effectively, any subsequent\
          #              calls to +success+ of +fails+ for this message will be\
          #              meaningless (and erroneous). +send_message+ and\
          #              +forward_message+ with <code>register?=false</code>\
          #              are equivalent.
          def forward_message msg, register=true
            # TODO implement
          end
          
          # Returns the medium BID if there is a message pending with the
          # given MID, nil otherwise.
          # 
          # Notice that this is a method that queries about native
          # messages (send by us). To query about forwarded messages,
          # one should use +forwarded?+.
          def pending? mid
            @pending[mid]
          end
          
          # call-seq:
          #     forwarded?(mid) -> [origin BID, medium BID]
          # 
          # Returns a pair of origin and medium BID for a forwarded message
          # pending for a delivery report with the given MID. If no such
          # message exists, returns nil.
          #
          # Notice that this is a method that queries about forwarded messages.
          # To query about native messages, one should use +pending?+.
          def forwarded? mid
            @forwarded[mid]
          end
          
          # call-seq:
          #     source_of(mid) -> bid or nil
          # 
          # Returns the BID of the buddy from which the message with the
          # specified MID came from. This assumes that the message with the
          # specified MID was forwarded and that it is still recorded in the
          # records (it has not been expired using +expire+).
          #
          # If the message with the given MID is not a forwarded message or if
          # it is not in the records any more, nil is returned.
          def source_of mid
            forwarded?(mid).first
          end

          # Creates a message with the given arguments. Makes sure that
          # everything is valid and coherent and if they are a 
          # +Message+ instance is returned. Otherwise a +MessageCentreException+
          # is raised. For specific exceptions thrown depending on the message
          # type or message arguments, read the documentation on +Message+
          # and +MessageTypes+.
          # === Arguments
          # * mtype: message type - found from the constants in module
          # +MessageTypes+.
          # * args: message arguments as defined by message semantics and
          # by the constraints found in module +MessageTypes+
          def create_message mtype, args
            # All checks done by constructors and stuff. We only need to
            # check the type and generate the ID.
            
            # this will raise an exception if type is wrong
            restrictions = message_restrictions mtype
            id = createID
            
            return Message.new(mtype, id, args, restrictions)
          end
          
          private ##############################################################
          def createID seed=nil
            seed = seed ? @digester.digest(seed + @id_seed) : @id_seed
            return @id_seed = @digester.digest(seed + DateTime.now.to_s)
          end
          
          # Does the actual labour work of sending a message, whether it
          # is forwarded or send.
          #
          # Arguments:
          # * message : a message of the appropriate class
          def post_message message
            # TODO complete
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
