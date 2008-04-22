$:.unshift File.join(File.dirname(__FILE__),'..','lib')

$isi = {}

require 'test/unit'
require 'trunk/isi/lib'
require 'pathname'
require 'trunk/isi/FreeChat/Protocol/MessageCentre/message'
require 'trunk/isi/freechat'

module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        class MessageTest < Test::Unit::TestCase
          def setup
            @bb = BuddyBook::BuddyBook.new
            @mc = MessageCentre.new(@bb, 'ECAC 373E 790B 985F 57A3  BEDD 4A1A EDA9 87C3 40FA')
            @mid = @mc.send :createID
            @args = {
              'mid' => @mid,
              'bid' => @mid+'_',
              'content' => 'EEEELa re ksanthia poy xathikes toson kairo'
            }
            @type = 12
            @message = Message.new @mid, @args, @type
          end
          
          def test_serialise
            puts(@message.serialise.dump)
          end
        end
      end
    end
  end
end
