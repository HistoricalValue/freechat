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
          def setup
            @bbq = BuddyBook::BuddyBook.new
            @bens = {
              'Kostas'  => [['66.66.66.66' , 6666 ], ['68.67.66.65'    , 6463]],
              'Marika'  => [['87.53.64.21' , 12000], ['162.11.54.69'   , 6969]],
              'Steve'   => [['54.12.33.21' , 300  ], ['33.67.103.100'  , 300 ],
                            ['23.67.32.55' , 300  ], ['125.124.122.100', 300 ]],
              'Aundrey' => [['21.133.87.59', 54281], ],
              'Miranda' => [['10.10.10.10' , 45   ], ],
              'Chandra' => [['20.30.40.120', 10   ], ],
              'Pekka'   => [['23.11.45.65' , 2000 ], ['23.11.45.123'   , 4312]],
            }
            [
              BuddyEntry.new('kostas', [
                Address.new('66.66.66.66', 6666), 
                Address.new('68.67.66.65', 6463)]),
              BuddyEntry.new('marika', [
                Address.new('87.53.64.21', 12000),
                Address.new('162.11.54.69', 6969)])
                ]
            @ui = FreeChatUI.new
            @link = Linker.new @ui, @bbq
            for b in @bens do @bbq << b end
          end
  
        end
      end
    end
  end
end
