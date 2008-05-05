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
            #   |                       |
            #  Miranda                Pekka
            #
            # "me" connects directly to Aundrey
            @link.buddy_connectable Aundrey ; assertions_after_Aundrey
          end
          
          private
          def assertions_after_Aundrey
            for bid in BIDs do 
              assert(!@link.buddy_present?(bid), bid + ' not supposed to be ' +
                  'known as present yet, but is marked so') \
                  unless bid == Aundrey
              assert(@link.buddy_present?(Aundrey), 'Aundrey is directly ' +
                  'connectable but she is not marked as present')
            end
          end
          
        end
      end
    end
  end
end
