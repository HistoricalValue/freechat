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
          
          def test_createID
            results = (1..100).to_a.map {
              @mc.send :createID
            }
            puts results.map{|s|s.dump}
            rrs = results.dup
            for rr in rrs do
              assert(results.include?(rr))
              to_del = []
              results.each_with_index { |e, i| 
                if e==rr then
                  to_del<<i
                  break
                end
              }
              assert(!to_del.empty?)
              for del in to_del do results.delete_at(del) end
              assert(!results.include?(rr))
            end
          end
        end
      end
    end
  end
end

