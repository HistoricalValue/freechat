module Isi
  module FreeChat
    module BuddyBook
      class BuddyBook
        Isi::db_hello __FILE__, name
        
        include Enumerable
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        def initialize
          @entries = {}
        end
        
        def [] bid
          @entries[bid]
        end
        
        def []= bid, entry
          raise ArgumentError.new("entry must be a #{BuddyEntry}") unless
              entry.is_a? BuddyEntry
          raise ArgumentError.new("entry must have same id as provided " \
              "for key: key=#{bid} =/= entry_id=#{entry.id}") unless
              bid.eql? entry.id
          @entries[bid] = entry
        end
        
        def << entry
          raise ArgumentError.new("entry must be a #{BuddyEntry}") unless
              entry.is_a? BuddyEntry
          @entries[entry.id] = entry
        end
        
        # Yields to the given block, passing BID and BuddyEntry as arguments.
        def each(&block)
          @entries.each(&block)
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
