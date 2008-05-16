$:.unshift File.join(File.dirname(__FILE__),'..')
$isi = {}

require 'test/unit'
require 'isi/freechat'


module Isi
  module FreeChat
    module PostOffice
      class AddressTest < Test::Unit::TestCase
        def setup
          @ip = '127.0.0.1'
          @ports = 39, 40
          @a0 = @az = Address.new(@ip, @ports.first)
          @a1 = Address.new(@ip, @ports.last)
          @an0 = @a0.dup
          @ann0 = @an0.dup
          @addresses = @a0, @az, @a1, @an0
        end

        def test_readers
          for a in @addresses
            assert(a.ip.eql?(@ip) && @ports.include?(a.port))
          end
        end

        def test_equalities
          assert(@a0.equal?(@az))     ; assert(!@a0.equal?(@an0))
          assert(@a0 == @az)          ; assert(@a0 == @an0)
          assert(@a0 === @az)         ; assert(@a0 === @an0)
          assert(@a0.eql?(@az))       ; assert(@a0.eql?(@an0))

          assert(!@az.equal?(@an0))   ; assert(!@an0.equal?(@a0))
          assert(@az == @an0)         ; assert(@an0 == @a0)
          assert(@az === @an0)        ; assert(@an0 === @a0)
          assert(@az.eql?(@an0))      ; assert(@an0.eql?(@a0))

          assert(@az.equal?(@a0))     ; assert(!@an0.equal?(@az))
          assert(@az == @a0)          ; assert(@an0 == @az)
          assert(@az === @a0)         ; assert(@an0 === @az)
          assert(@az.eql?(@a0))       ; assert(@an0.eql?(@az))

          assert(!@an0.equal?(@ann0)) ; assert(!@ann0.equal?(@a0))
          assert(@an0 == @ann0)       ; assert(@ann0 == @a0)
          assert(@an0 === @ann0)      ; assert(@ann0 === @a0)
          assert(@an0.eql?(@ann0))    ; assert(@ann0.eql?(@a0))
          
          assert(@a1 != @a0) ; assert(@a1 != @an0) ; assert(@a1 != @ann0)
        end
      end
    end
  end
end
