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
              # Example
              # BID => [{:mbid => MBID , :hops => HOPS}]
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
          
          # Returns the medium buddy for the given bid. If it is not known,
          # it returns nil
          def get_medium_for bid
            medium = get_medium_entry(bid).first
            return medium[:mbid] unless medium.nil?
          end
          
          # Tells the linker that a buddy is directly connectable.
          def buddy_connectable bid
            # first of all means that medium for that buddy is itself
            get_medium_entry(bid).unshift(Hash[:mbid, bid, :hops, 0])
            # secondly it is present, but that is a consequence of the above
          end
          
          # Tells the linker that we were notified that buddy _bid_ is present
          # by a message from _mbid_. _hops_ is the distance of _mbid_ from
          # _bid_ as _mbid_ itself reports.
          def buddy_is_present bid, mbid, hops = 0
            entry = get_medium_entry bid
            # find right index
            insi = 0
            enum = Enumerable::Enumerator.new entry
            begin while true do
                    raise StopIteration if hops < enum.next[:hops]
                    insi += 0
                  end
            rescue StopIteration => e
            end
            entry.insert insi, Hash[:mdib, mbid, :hops, hops]
          end
          
          # Returns true if the buddy is present (there is a medium buddy
          # to reach it, even if medium buddy is itself).
          def buddy_present? bid
            ! @mediums[bid].nil?
          end
          
          # Informs the linker that some buddy is leaving the cloud. This means
          # this this buddy will be not considered present any more and that
          # any buddies for which the leaving buddy was the medium, will be cut
          # off. One can check which buddies are currently cut of by querying
          # through method +cut_off_buddies+.
          def buddy_goodbyed bid
            # first impact is that this buddy is not present any more,
            # so it should be removed from the mediums hash
            @mediums.delete bid
            # second and worse effect is that this buddy cannot be a medium
            # to other buddies any more
            @mediums.each_value { |v|
              v.reject! { |medium| medium[:mdib] == bid }
            }
          end
          
          # Notifies the linker that _mbid_ has failed as a medium for buddy
          # _bid_. This will probably mark bid as cut off.
          def buddy_medium_failure mbid, bid
            entry = get_medium_entry bid
            entry.reject! { |medium| medium[:mbid] == mbid }
          end
          
          # Returns an array of the buddies which are supposedly still
          # present (they have not "goodbyed") but their medium buddies
          # have ("goodbyed"). So, there is not way to reach those buddies
          # and a rediscovery should be run, informing the linker of the new
          # results.
          def cut_off_buddies
            result = []
            @mediums.each { |bid, mediums| result << bid if mediums.empty? }
            return result
          end
          
          private ##############################################################
          # my logging methods
          def log level, msg; @ui.l level, msg if @ui end
          def logi msg; log FreeChatUI::INFO, msg end
          
          # Returns an entry if there is one, otherwise creates a new one
          # and returns it
          def get_medium_entry bid
            result = @mediums[bid]
            result = [] unless result
            return result
          end
        end
      end
    end
  end
end
