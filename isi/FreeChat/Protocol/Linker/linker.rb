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
        class Linker
          # === Arguments
          # * bbq : a BuddyBook
          # * po : a PostOffice
          # * ui : a FreeChatUI
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
            # Untrusted addresses is simply an array of addresses which we
            # don't know which buddy (or whom in general) is using it
            @untrusted_addresses = []
          end
          
          # Means that the given buddy has initiated a connection from the
          # given address, and therefore this address can be used for sending
          # messages to/through that buddy.
          def buddy_using_address bid, addr
            addrs = @special_addresses[bid]
            @special_addresses[bid] = addrs = [] unless addrs
            addrs.unshift addr
            # assert
            raise unless addr.is_a? Isi::FreeChat::PostOffice::Address
          end
          
          # Gets the appropriate address for the bid.
          # *NOTICE* this is NOT the address of the medium buddy. This is an
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
            entry = @bbq[bid]
            normal  = if entry.nil? then nil else entry.addresses end
            # TODO _retry should rearrange the addresses
            return case
                when special then special.at _retry
                when normal  then normal.at _retry
                else nil
                end
          end

          @@array_of_a_nil_returning_lambda = lambda { [ nil ] }
          # Returns the buddy-id of the buddy who is supposed to be using the
          # given address currently. It could be a special address that has
          # been registered earlier by calling +buddy_using_address+ or it
          # can be a regular address for a buddy found in the address book.
          #
          # If no buddy is found using this address (anywhere), then _nil_ is
          # returned.
          def get_buddy_using_address addr
            raise UntrustedAddressUse if address_untrusted?(addr)
            result = @special_addresses.find { |bid, addresses|
              addresses.include? addr
            }
            return result.first if result # special address using buddy
            # (result = nil) No special address like that; find from BBQ
            @bbq.find(@@array_of_a_nil_returning_lambda) {|id, entry|
              # don't forget, bbq is a hash
              entry.addresses.include?(addr)
            }.first
          end
          
          # Registers the given address as untrusted. If it used in any
          # operation (other than "remove_untrusted_address") an 
          # +UntrustedAddressUsed+ error will be raised.
          def register_untrusted_address addr
            @untrusted_addresses << addr
          end
          # Returns true if given address is currently marked as untrusted
          def address_untrusted? addr
            @untrusted_addresses.include? addr
          end
          alias_method :untrusted_address?, :address_untrusted?
          # Removes an address from the list of untrusted addresses.
          def remove_untrusted_address addr
            @untrusted_addresses.delete addr
          end
          
          # call-seq:
          #     get_medium_for(bid) => {:mbid => MBID, :hops => hops}
          # 
          # Returns the medium buddy for the given bid. If it is not known,
          # it returns nil.
          def get_medium_for bid
            medium = @mediums[bid]
            return nil unless medium
            medium = medium.first
            return medium unless medium.nil?
          end
          
          # Tells the linker that a buddy is directly connectable to the
          # address given. Currently there are no checks made for the given
          # address (whether is it actually connectable, whether it belongs
          # indeed to this buddy (according to buddybook), etc).
          def buddy_connectable bid, addr=nil
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
                    insi += 1
                  end
            rescue StopIteration => e
            end
            entry.insert insi, Hash[:mbid, mbid, :hops, hops]
          end
          
          # Returns true if the buddy is present (there is a medium buddy
          # to reach it, even if medium buddy is itself).
          def buddy_present? bid
            ! @mediums[bid].nil?
          end

          # Passes an array like
          #     [BID, [{:mbid => MBID, :hops => hops}, ...]]
          # to the given block or evaluates to an enumerator for the above if
          # no block is given.
          def present_buddies(&block)
            if block then @mediums.each(&block) else @mediums.to_enum end
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
            entry = @mediums[bid]
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
            @mediums[bid] = result = [] unless (result = @mediums[bid])
            result
          end
        end
      end
    end
  end
end
