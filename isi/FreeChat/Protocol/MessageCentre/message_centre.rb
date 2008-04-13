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
            # this MC. Information is stored in triplets (Arrays of three
            # elements:
            # * at(0) = Origin BID: the buddy from which this message arrived
            # * at(1) = MID: the message id
            # * at(2) = BuddyCloudGateID: the buddy through which it is 
            #                             forwarded
            @forwared = {}
          end
          
          

          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
