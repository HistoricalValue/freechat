$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'trunk/isi/lib'

class IsilibTest < Test::Unit::TestCase
  def test_bytes
    s = 0xa032f1456a2b1c
    bytes = s.bytes
    p = Integer.from_bytes bytes
    assert_equal s, p
    assert_not_equal s.__id__, p.__id__
  end
end
