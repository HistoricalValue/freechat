module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        # Defines as constants the message types and the message arguments'
        # keys. Also provides methods for checking the validity of message
        # types, message arguments, message types' names, etc.
        #
        # Information on message types and their arguments constraints:
        # == Statements 
        # === Statement:Delivery Success (STM_DELIVERY_SUCCESS)
        # Indicates that a message was successfully delivered.
        # ==== Arguments
        # * mid:String : message ID which the delivery report concerns
        # * rcp:String : the recipient BID (of this message)
        # === Statement:Deliery Failure (STM_DELIVERY_FAILURE)
        # Indicates that a message failed to be delivered to the recipient.
        # ==== Arguments
        # * mid:String : message ID which the delivery report concerns
        # * rcp:String : the recipient BID (of this message)
        # === Statement:Present (STM_PRESENT)
        # Indicates that some buddy is present
        # ==== Arguments
        # * bid:String : who is present
        # * rcp:String : the recipient BID (of this message)
        # === Statement:Goodbye (STM_GOODBYE)
        # Indicates that some buddy is leaving us.
        # This message concerns everybody, has no specific recipient.
        # ==== Arguments
        # * bid:String : who is leaving
        # === Statement:Message (STM_MESSAGE)
        # A message going to another buddy. It has a
        # a content and it will be hopping from node to node, so the content
        # should not be long. For long contents, a direct connection should
        # be made. It can be requested with REQ_DIRECT
        # ==== Arguments
        # * cnt:String : the content of this message (bytes)
        # * rcp:String : the recipient BID (of this message)
        # * frm:String : BID of the sender of this message
        # === Statement:Hello (STM_HELLO)
        # A message indicating that some buddy has become
        # available. It has no specific recipient, concerns everybody.
        # ==== Arguments
        # * bid:String : who became available
        # === Statement:Direct (STM_DIRECT)
        # A message send as a response to REQ_DIRECT when
        # the direct connection has been initiated.
        # ==== Arguments
        # * rcp:String : the recipient of this message (BID) (the one who sent
        # REQ_DIRECT)
        # * frm:String : the sender of this message (BID) (the one who connects
        #   to "rcp")
        # == Requests
        # === Request:Presence (REQ_PRESENCE)
        # Requests the presence status of a given buddy.
        # Anyone who already knows that the specified buddy is available,
        # can reply with a STM_PRESENT
        # ==== Arguments
        # * bid:String : BID of the buddy in question
        # === Request:Direct (REQ_DIRECT)
        # Requests that some buddy iniates a direct connection
        # with the sender of this message. The receiver of this message is
        # supposed to connect directly to the sender and when this happens,
        # send him a STM_DIRECT message.
        # ==== Arguments
        # * rcp:String : the recipient BID (of this message)
        # * frm:String : BID of the sender of this message        
        module MessageTypes
          Isi::db_hello __FILE__, name

          ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last

          # Message arguments' keys #############
          MID = 'mid' ; RCP = 'rcp' ; BID = 'bid'
          CNT = 'cnt' ; FRM = 'frm' ;
          # aliases
          MESSAGE_ID = MID ; RECIPIENT = RCP ; BUDDY_ID = BID
          CONTENT    = CNT ; FROM      = FRM ;
          
          # Statements #############
          # Statement:Delivery Success: indicates that a message was
          # successfully delivered.
          # === Arguments
          # * mid:String : message ID which the delivery report concerns
          # * rcp:String : the recipient BID (of this message)
          STM_DELIVERY_SUCCESS = 0x00
          # Statement:Deliery Failure: indicates that a message failed to
          # be delivered to the recipient.
          # === Arguments
          # * mid:String : message ID which the delivery report concerns
          # * rcp:String : the recipient BID (of this message)
          STM_DELIVERY_FAILURE = 0x01
          # Statement:Presence: indicates that some buddy is present
          # === Arguments
          # * bid:String : who is present
          # * rcp:String : the recipient BID (of this message)
          STM_PRESENT          = 0x02
          # Statement:Goodbye: indicates that some buddy is leaving us.
          # This message concerns everybody, has no specific recipient.
          # === Arguments
          # * bid:String : who is leaving
          STM_GOODBYE          = 0x03
          # Statement:Message: a message going to another buddy. It has a
          # a content and it will be hopping from node to node, so the content
          # should not be long. For long contents, a direct connection should
          # be made. It can be requested with REQ_DIRECT
          # === Arguments
          # * cnt:String : the content of this message (bytes)
          # * rcp:String : the recipient BID (of this message)
          # * frm:String : BID of the sender of this message
          STM_MESSAGE          = 0x04
          # Statement:Hello: a message indicating that some buddy has become
          # available. It has no specific recipient, concerns everybody.
          # === Arguments
          # * bid:String : who became available
          STM_HELLO            = 0x05
          # Statement:Direct: a message send as a response to REQ_DIRECT when
          # the direct connection has been initiated.
          # === Arguments
          # * rcp:String : the recipient of this message (BID) (the one who sent
          # REQ_DIRECT)
          # * frm:String : the sender of this message (BID) (the one who connects
          # to "rcp")
          STM_DIRECT           = 0x06

          # Requests ############
          # Request:Presence: requests the presence status of a given buddy.
          # Anyone who already knows that the specified buddy is available,
          # can reply with a STM_PRESENT
          # === Arguments
          # * bid:String : BID of the buddy in question
          REQ_PRESENCE         = 0x10
          # Request:Direct: requests that some buddy iniates a direct connection
          # with the sender of this message. The receiver of this message is
          # supposed to connect directly to the sender and when this happens,
          # send him a STM_DIRECT message.
          # === Arguments
          # * rcp:String : the recipient BID (of this message)
          # * frm:String : BID of the sender of this message
          REQ_DIRECT           = 0x11
          
          # Returns a +Hash+ which contains all valid message types (as defined
          # in the constants referring to message types in this module)
          # associated with their names.
          def self.message_types
            result = constants(false)
            result.reject! { |const_name| (const_name =~ /^(REQ|STM)_/).nil? }
            result.map! {|const_name| const_get const_name, false }
            return result
          end
          # Instance method version of +MessageTypes::message_types+
          def message_types(*args, &block)
            MessageTypes::message_types(*args, &block)
          end

          # Checks if a given message type is valid (is a value from the 
          # constants referring to message types defined in this module)
          def self.valid_message_type? mtype
            message_types.any? {|vmt| vmt.eql?(mtype) && mtype.eql?(vmt) }
          end
          # Instance method version of ++
          def valid_message_type?(*args, &block)
            MessageTypes::valid_message_type?(*args, &block)
          end
          
          # Message argument restrictions is an +Hash+ which contains the
          # +Hash+es appropriate to pass as arguments to new messages.
          # Keys in the Hash are the names of the message types, as defined 
          # as constants in this module.
          MessageRestrictions = {
            'STM_DELIVERY_SUCCESS' => {'mid' => String, 'rcp' => String},
            'STM_DELIVERY_FAILURE' => {'mid' => String, 'rcp' => String},
            'STM_PRESENT'          => {'bid' => String, 'rcp' => String},
            'STM_GOODBYE'          => {'bid' => String},
            'STM_MESSAGE'          => {
              'cnt' => String, 'rcp' => String, 'frm' => String},
            'STM_HELLO'            => {'rcp' => String},
            'STM_DIRECT'           => {'rcp' => String, 'frm' => String},
            'REQ_PRESENCE'         => {'bid' => String},
            'REQ_DIRECT'           => {'rcp' => String, 'frm' => String},
          }
          
          # Returns an array of the message type names, as defined as constants
          # in this module.
          def self.message_types_names
            constants.map(&Isi::Procs[:to_s]).reject { |const_name|
              (const_name =~ /^(STM|REQ)_/).nil?
            }
          end
          # Instance method version of +MessageTypes::message_types_names+
          def message_types_names(*args, &block)
            MessageTypes::message_types_names(*args, &block)
          end
          
          # Returns a Hash with message types names mapped to message types,
          # as defined as constants in this module.
          def self.message_types_with_names
            result = {}
            message_types_names.each { |name| result[name] = const_get name }
            return result
          end
          # Instance method version of
          def message_types_with_names(*args, &block)
            MessageTypes::message_types_with_names(*args, &block)
          end
          
          # Returns the hash which is appropriate for a new message as
          # argument restrictions. Checks if the given message type is
          # a valid type and if it is, it returns the appropriate restrictions.
          # If it is not it raises a +MessageCentreException+.
          def self.message_restrictions message_type
            vmts = message_types
            raise MessageCentreException.new('Invalid message type: ' +
                "#{message_type} (not in) #{vmts}") \
                unless vmts.include? message_type
            # we do not want any nils now
            type_name = message_types_with_names.invert[message_type]
            raise message_type.inspect if type_name.nil?
            result = MessageRestrictions[type_name]
            raise type_name.inspect if result.nil?
            return result
          end
          # Instance method version of +MessageTypes::message_restrictions+.
          def message_restrictions(*args, &block)
            MessageTypes::message_restrictions(*args, &block)
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
