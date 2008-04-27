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
        class Linker
          def initialize bbq, ui = nil
            @bbq = bbq
            @ui = ui
            # Mediums is a hash which maps bids to medium bids
            @mediums = {}
            # Special addresses: Maps bid to address which should be used
            # instead of the ones in address book
            @special_addresses = {}
          end
          
          # Means that the given buddy has initiated a connection from the
          # given address, and therefore this address can be used for sending
          # messages to/through that buddy.
          def buddy_using_address bid, addr
            addrs = @special_addresses[bid]
            addrs = [] unless addrs
            addrs.unshift addr
            # assert
            raise unless addr.is_a? Isi::FreeChat::PostOffice::Address
          end
          
          # Gets the appropriate address for the bid.
          # *NOTICE* this is the address of the medium buddy. This is an
          # appropriate address that buddy _bid_ is actually using.
          # If the _retry-ies are too many or if there is no address for this
          # buddy at all, this method returns nil.
          # 
          # === Arguments
          # * bid: the bid of the buddy
          # * _retry: which retry is this? If an address returned previously
          # by this method causes problems, there might be another address.
          # _retry starts from 0 and can be incremented until this method 
          # returns nil.
          def get_address_of bid, _retry = 0
            special = @special_addresses[bid]
            normal  = @bbq[bid].addresses
            # if retry is >0 it means some address is faulty, we should mark
            # that.
            # For special addresses, just remove them. For address book addresses
            # rearrage them
            if _retry > 0 then
              case
              when special then special.shift
              when normal then normal.push normal.shift
              end
            end
            return special ? special.first : normal ? normal.first : nil
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
