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
            @bens = [BuddyEntry.new('kostas', [Address.new('66.66.66.66', 6666), 
                Address.new('68.67.66.65', 6463)]),
                     BuddyEntry.new('marika', [Address.new('87.53.64.21', 12000),
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
