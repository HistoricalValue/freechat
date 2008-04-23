module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        module MessageTypes
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
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
        # be made. It can be requested with STM_DIRECT
        # === Arguments
        # * cnt:String : the content of this message (bytes)
        # * rcp:String : the recipient BID (of this message)
        STM_MESSAGE          = 0x04

        Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
