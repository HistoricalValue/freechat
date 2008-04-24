
def m
	A.new.valid_message_types
end

class A
	include Isi::FreeChat::Protocol::MessageCentre::MessageTypes
end

