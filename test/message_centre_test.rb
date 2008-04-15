$:.unshift File.join(File.dirname(__FILE__),'..')

$isi = {}

require 'test/unit'
require 'isi/freechat'

module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        class MessageCentreTest < Test::Unit::TestCase
          def setup
            @ab = Isi::FreeChat::BuddyBook::BuddyBook.new
            @mc = MessageCentre.new @ab
            @failure_key = 123
          end
          
          def test_prelim
            @mc.failure @failure_key
            fs = @mc.instance_variable_get(:@failures)
            assert(fs.has_key?(@failure_key))
          end
        end
      end
    end
  end
end

