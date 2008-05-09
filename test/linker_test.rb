$:.unshift File.join(File.dirname(__FILE__),'..')

$isi = {
#  :debug_hello => true,
#  :debug_bye => true,
}

require 'test/unit'
require 'trunk/isi/freechat'
include Isi::FreeChat::Protocol::Linker
include Isi::FreeChat::BuddyBook
include Isi::FreeChat::PostOffice
include Isi::FreeChat

module Isi
  module FreeChat
    module Protocol
      module Linker
        class LinkerTest < Test::Unit::TestCase
          
          # Bids
          Kostas = 'Kostas'
          Marika = 'Marika'
          Steve  = 'Steve'
          Aundrey= 'Aundrey'
          Miranda= 'Miranda'
          Chandra= 'Chandra'
          Pekka  = 'Pekka'
          BIDs = [Kostas, Marika, Steve, Aundrey, Miranda, Chandra, Pekka, ]
          
          def setup
            @bbq = BuddyBook::BuddyBook.new
            @bens = {
              Kostas  => [['66.66.66.66' , 6666 ], ['68.67.66.65'    , 6463]],
              Marika  => [['87.53.64.21' , 12000], ['162.11.54.69'   , 6969]],
              Steve   => [['54.12.33.21' , 300  ], ['33.67.103.100'  , 300 ],
                          ['23.67.32.55' , 300  ], ['125.124.122.100', 300 ]],
              Aundrey => [['21.133.87.59', 54281], ],
              Miranda => [['10.10.10.10' , 45   ], ],
              Chandra => [['20.30.40.120', 10   ], ],
              Pekka   => [['23.11.45.65' , 2000 ], ['23.11.45.123'   , 4312]],
            }
            @ui = FreeChatUI.new
            for name, addresses in @bens do
              addresses.map! { |ip, port| Address.new ip, port }
              @bbq << BuddyEntry.new(name, addresses)
            end
            @link = Linker.new @bbq, @ui
          end
  
          def test_scenario1
            # Buddy graph:
            #
            #          ,--- Marika    Chandra
            # Steve --<                 |
            #   |      `------------ Aundrey --- Kostas
            #   |                       |   `---.
            #  Miranda                Pekka      `--- "I"--- Lea
            #
            # "me" connects directly to Aundrey
            @link.buddy_connectable Aundrey ; assertions_after_Aundrey
            # pseudo discovery process:
            # Aundrey says that Chandra, Kostas, Pekka and Steve are present
            presents = []
            presents2b = [Chandra, Kostas, Pekka, Steve]
            while !presents2b.empty? do
              presents.push(new_present = presents2b.pop)
              @link.buddy_is_present new_present, Aundrey, 1
              assertions_after_Aundrey_hop_1_group presents
            end
            # later (for no reason [this would normally not happen])
            # chandra, kostas, pekka and steve say that they are MIDs for
            # each other. All of them have hops>1 because they all MID
            # through Aundrey. So this should not affect the assertions of
            # the previous step at all.
            loles = [Chandra, Kostas, Pekka, Steve]
            for lola in loles do
              for loli in loles-[lola] do
                @link.buddy_is_present loli, lola, 2
                assertions_after_Aundrey_hop_1_group(presents)
              end
            end
          end
          
          private
          def assertions_after_Aundrey_hop_1_group presents
            # common checks
            for bid in BIDs do
              # Their address must be one of the provided ones
              assert_valid_address(bid)
              # Retrying too much for an address must return nil
              assert_too_many_retries_for_address_is_nil(bid)
            end
            # checks for non-present buddies
            for bid in BIDs do
              unless bid == Aundrey || presents.include?(bid)
                # They must not be present
                assert_not_present(bid)
                # we know no mediums for those buddies yet
                assert_no_medium_for(bid)
              end
            end
            # checks for presents buddies
            for bid in presents do
              # they must be present
              assert_is_present(bid, Aundrey, 1)
              # their address must be from the buddy book (although not used
              # for message sending)
              assert_valid_address(bid)
              # medium must be aundrey with hop 1
              assert_medium_validity(bid, Aundrey, 1)
            end
            # no cut off people yet
            assert_cutoff []
          end
          
          def assertions_after_Aundrey
            # make checks for buddies other than Aundrey
            for bid in BIDs do 
              unless bid == Aundrey
                # They must not be present
                assert_not_present(bid)
                # Their address must be one of the provided ones
                assert_valid_address(bid)
                # Retrying too much for an address must return nil
                assert_too_many_retries_for_address_is_nil(bid)
                # we know no mediums for those buddies yet
                assert_no_medium_for(bid)
              end
            end
            assert_directly_connectable_is_present(Aundrey)
            assert(@bens[Aundrey].include?(@link.get_address_of(Aundrey)),
                "Address of #{Aundrey} comes from space")
            assert((a = @link.get_medium_for(Aundrey)[:mbid]) == Aundrey,
                "#{Aundrey} is not the medium for herself although she is " +
                'directly connectable. Mbid is ' + a.to_s)
            assert((a = @link.get_medium_for(Aundrey)[:hops]) == 0,
                "#{Aundrey} is directly connectable but her hops are #{a}")
            assert((a = @link.cut_off_buddies).empty?, 
                "Nobody should be cut off yet: #{a}")
          end
          
          def assert_not_present bid
            assert(!@link.buddy_present?(bid), bid +
                  ' not supposed to be ' +
                  'known as present yet, but is marked so')
          end
          
          def assert_valid_address bid
            @bens[bid].length.times { |_retry|
              assert(@bens[bid].
                  include?(a = @link.get_address_of(bid, _retry)),
                  "bid(#{bid})'s #{_retry}th address (#{a}) is not " +
                  'found in buddy book data (' + @bens.inspect + ')')
            }
          end
          
          def assert_too_many_retries_for_address_is_nil(bid)
            assert((a = @link.get_address_of(bid, @bens[bid].length)).nil?,
                "bid(#{bid})'s #{@bens[bid].length}th address (#{a}) " +
                'should be null')
          end
          
          def assert_no_medium_for(bid)
            assert((a = @link.get_medium_for(bid)).nil?,
                "medium for buddy #{bid} should be unknown but is " +a.to_s)
          end
          
          def assert_directly_connectable_is_present(bid)
            assert(@link.buddy_present?(bid), bid + ' is directly ' +
                'connectable but is not marked as present')
          end
          
          def assert_is_present(bid, mid, hops)
            assert(@link.buddy_present?(bid), bid + ' should be present ' +
                "through #{mid}:#{hops}")
          end
          
          def assert_medium_validity(bid, mbid, hops)
            medium = @link.get_medium_for(bid)
            assert(!medium.nil?, "medium for #{bid} is nil. Should be " +
                "#{mbid}:#{hops}")
            assert((a = medium[:mbid]) == mbid, "medium for #{bid} is " +
                a.inspect + ". Should be #{mbid}")
            assert((a = medium[:hops]) == hops, "hops for #{bid} is #{a}. " +
                "Should be #{hops}")
          end
          
          def assert_cutoff who
            cutoffs = @link.cut_off_buddies
            for cutoff in cutoffs do
              assert(who.include?(cutoff), "#{cutoff} no included in list " +
                  "of cutoff buddies: #{cutoffs.inspect} " +
                  "(should-be: #{who.inspect})")
            end
          end
          
        end
      end
    end
  end
end
