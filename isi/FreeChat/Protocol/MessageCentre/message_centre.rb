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
          # Besides the operations described on each method, message centre
          # also has an attribute, message_store, which is a +Hash+ which
          # keeps pairs of message-ids and messages.
          #
          # === Arguments
          # * po:      a post office to send messages
          # * linker:  the linker to use for messages
          # * id_seed: used in generating message IDs which are hopefully\
          #            spatially and timely unique. It is not used directly\
          #            in the ID generation, but it is first digested with\
          #            an 512bit SHA2 digester
          def initialize po, linker, ui = nil
            id_seed = ((rand+rand+rand).to_s + DateTime.now.to_s).crypt('f6')
            @po = po
            @linker = linker
            @ui = ui
            @digester = Digest::SHA2.new 512
            # id_seed is used in generating message IDs which are hopefully
            # spatially and timely unique
            @id_seed = @digester.digest id_seed
            # Stores pairs of MID-message. Completely manipulated externally.
            @message_store = {}
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
          attr_reader :message_store
          
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
            recipient = msg['rcp']
            # when the message has a recipient, try to send it there
            if recipient then
              medium = @linker.get_medium_for recipient
              post_message medium, msg
              @pending[msg.id] = medium if register
              logf "#({register})pending[#{msg.id} =1 #{medium}"
            else
              # send it to everyone we can
              for bentry in @bbq do
                if (medium = @linker.get_medium_for bentry.id) then
                  post_message medium, msg
                  @pending[msg.id] = medium
                  logf "(#{register})pending[#{msg.id} =N #{medium}"
                end
              end
            end
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
            recipient = msg['rcp']
            # when the message has a recipient, try to send it there
            if recipient then
              medium = @linker.get_medium_for recipient
              post_message medium, msg
              @forwarded[msg.id][1] = medium if register
              logf "#({register})forwarded[#{msg.id}].medium =1 #{medium}"
            else
              # send it to everyone we can
              for bentry in @bbq do
                if (medium = @linker.get_medium_for bentry.id) then
                  post_message medium, msg
                  @pending[msg.id] = medium
                  logf "(#{register})forwarded[#{msg.id}].medium =N #{medium}"
                end
              end
            end
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

          # Registers the given mid as the origin buddy of msg.
          def received_from bid, msg
            buddies = @forwarded[msg.id]
            unless buddies then buddies = [bid]
                           else buddies[0] = bid
                           end
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
          def create_message mtype, args={}
            # All checks done by constructors and stuff. We only need to
            # check the type and generate the ID.
            
            # this will raise an exception if type is wrong
            restrictions = message_restrictions mtype
            id = createID
            
            return Message.new(mtype, id, args, restrictions)
          end

          # Transforms the given message to a human friendly string (it loves
          # humans).
          def message_to_s msg
            "#{type_to_s msg}:#{Hash[msg.each_argument.to_a].inspect}"
          end
          
          # Transforms a message type to a string. The resulting string is in 
          # fact the name of the constant for the message type in module
          # +MessageTypes+.
          # NOTICE: the argument of this method is a message and not a message
          # type. Message type is supposedly an oblique concept.
          def type_to_s msg
            tn = message_types_with_names
            pair = tn.rassoc(normalise_type(msg.type))
            pair.at(0).to_s if pair
          end
          
          # Returns a new *+Message+* from the serialised data provided.
          # 
          # Notice that this is quite different from +Message::deserialise+.
          # It does not return an array of message data but a ready message.
          # It also transforms message_type to the right type.
          def deserialise sdata
            type, mid, args = Message::deserialise sdata
            type = Integer::from_bytes(type.bytes.to_a)
            return Message::new(type, mid, args)
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
          # * recipient: the recipient bid (NOT THE ACTUAL RECIPIENT, THE MEDIUM
          # FOR EXAMPLE)
          # * message : a message of the appropriate class
          def post_message recipient, message
            @po.send_to @linker.get_address_of(recipient), message.serialise
          end
          
          # Assumes that message type has not been tampered with and tried
          # to convert it back to integer. All message fields are read as
          # strings from the serialised data and are not converted back
          # automatically by +Message#deserialise+ because it cannot know what
          # the message creator had in mind for each field. We (as the
          # message centre) are the creator of messages though and we know that
          # (in normal cases) message type should be an Integer. The string
          # probably holds the integer bytes, and as such we will try to convert
          # it back.
          def normalise_type msg_type
            case
            when msg_type.class <= String then
              return Integer::from_bytes(msg_type.bytes.to_a)
            when msg_type.class <= Integer then return msg_type
            else raise 'Unknown msg_type'
            end
          end
          
          # My loggings
          def log level, msg; @ui.mc level, msg end
          def logf msg; log FreeChatUI::FINE, msg end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
