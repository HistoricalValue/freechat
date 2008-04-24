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