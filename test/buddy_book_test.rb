$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$isi = {} 
require 'test/unit'
require 'trunk/isi/freechat'

module Isi
  module FreeChat
    module BuddyBook
      require ModuleRootDir + 'buddy_book'
      class BuddyBookTest < Test::Unit::TestCase
        
        def setup
          puts 'hello'
          @bb = BuddyBook.new
          @wrong_id = 'slin'
          @ids = ['psyx', 'dros', 'nand']
          @entries = [
            BuddyEntry.new(@ids.at(0), []),
            BuddyEntry.new(@ids.at(1), []),
            BuddyEntry.new(@ids.at(2), []),
          ]
          for entry in @entries do @bb << entry end
        end
        
        def teardown
          puts 'bye'
        end
        
        def test_access
          for id in @ids do
            e = @bb[id]
            assert_not_nil e
            assert_equal(id, e.id)
          end
          e = @bb[@wrong_id]
          assert_nil e
        end
        
        def test_write
          te = BuddyEntry.new 'sofos', []
          begin
            @bb[@ids.at(0)] = te
            flunk 'should raise argument error (different BIDs)'
          rescue ArgumentError => e
          end
          begin
            @bb[te.id] = Object.new
            flunk 'should raise argument error (not B-entry)'
          rescue ArgumentError => e
          end
          @bb << te
          e = @bb[te.id]
          assert_not_nil e
          assert_equal(te.id, e.id)
        end
      end
    end
  end
end
