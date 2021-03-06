module Isi
  module FreeChat
    module BuddyBook
      class BuddyEntry
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        def initialize id, addresses=nil
          @id = id.to_s
          @addresses = addresses.to_a
        end
        attr_reader :id, :addresses
        
        # Returns a string like
        #    "#{id}: #{addresses.join(' ')}"
        def to_s
          "#{id}: #{addresses.join(' ')}"
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
