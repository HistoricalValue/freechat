module Isi
  module FreeChat
    module Protocol
      module Linker
        # Linker is the class responsible for knowing how each Buddy can
        # be actually reached (through which other buddy, etc). This is
        # done by interpreting some significant events, implemented as methods
        # in this class.
        # 
        # It is also the place to get an address for a bid from.
        # 
        # === Arguments
        # * bbq : a BuddyBook
        # * po : a PostOffice
        # * ui : a FreeChatUI
        class Linkern
          def initialize bbq, ui = nil
            @bbq = bbq
            @ui = ui
            # Mediums is a hash which maps bids to medium bids
            @mediums = {}
            # Special addresses: Maps bid to address which should be used
            # instead of the ones in address book
            @addr = {}
          end
          
          # Means that the given buddy has initiated a connection from the
          # given address, and therefore this address can be used for sending
          # messages to/through that buddy.
          def buddy_using_address bid, addr
            
          end
          
          private ##############################################################
          # my logging methods
          def log level, msg; @ui.l level, msg if @ui end
          def logi msg; log FreeChatUI::INFO, msg end
        end
      end
    end
  end
end
