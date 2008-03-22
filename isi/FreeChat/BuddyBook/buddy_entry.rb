module Isi
  module FreeChat
    module BuddyBook
      class BuddyEntry
        def initialize id, addresses=nil
          @id = id.to_s
          @addresses = addresses.to_a
        end
        attr_reader :id, :addresses
      end
    end
  end
end
