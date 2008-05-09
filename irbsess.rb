$isi = {} 
require 'isi/lib'
require 'isi/freechat'
include Isi::FreeChat::Protocol::MessageCentre::MessageTypes
def m
	A.new.message_restrictions A::STM_MESSAGE
end

class A
	include Isi::FreeChat::Protocol::MessageCentre::MessageTypes
end

def lol; yield end; def lal(*args, &block); lol(*args, &block) end

def hi; 'hi' end
def a; A.new end

Hl = Class.new {
	include Enumerable
	define_method(:initialize, &lambda { |v| instance_variable_set :@v, v})
}

class Hm 
include Enumerable
def initialize v = 12; @v = v end; attr_reader :v
def <=> o; v <=> o.v end
def each(&b); i = v; while i > 0 do b.call(i); i -= 1 end end
def to_s; to_a.to_s end
def inspect; to_a.inspect end
end

def ct
  v = catch(:hi) { |i|
    p i
    throw :hi
  }
  p v
end

def fct
  v = catch(:hi) { |i|
    p i
    throw :ble
  }
  p v
end

def et
	enum = Enumerable::Enumerator.new []
	while true do 
		puts 'lola' if enum.next
	end
end
