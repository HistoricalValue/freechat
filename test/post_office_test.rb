$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$isi = {
  :debug_hello => false,
  :debug_bye => false,
}
require 'test/unit'
require 'trunk/isi/freechat'
require 'socket'

module Isi
  module FreeChat
    module PostOffice
      require ModuleRootDir + 'post_office'
      class PostOfficeTest < Test::Unit::TestCase
        
        def setup
          @my_addr = Address.new '127.0.0.1', 12000
          @po = PostOffice.new @my_addr
          @addr = Address.new '127.0.0.1', 12000
        end
        
        def teardown
          @po.close_down
        end
        
        def test_send_to
          @po.send_to(@addr, "deth re \ndeth ")
        rescue  => e
          flunk e.to_s
        end
        
        def test_reachable?
          @po.reachable? @addr
        rescue => e
          flunk e.to_s
        end
        
        # def test_foo
          # assert(false, 'Assertion was false.')
          # flunk "TODO: Write test"
          # assert_equal("foo", bar)
        # end
      end
    end
  end
end
