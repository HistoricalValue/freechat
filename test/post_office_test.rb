$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$isi = {} 
require 'test/unit'
require 'trunk/isi/freechat'

module Isi
  module FreeChat
    module PostOffice
      require ModuleRootDir + 'post_office'
      class PostOfficeTest < Test::Unit::TestCase
        
        def setup
          @po = PostOffice.new
          @addr = Address.new '127.0.0.1', 12000
        end
        
        def teardown
          puts 'bye'
        end
        
        def test_send_to
          @po.send_to(@addr, 'deth')
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
