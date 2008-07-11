module Isi
  module FreeChat
    module BuddyBook
      class BuddyBook
        Isi::db_hello __FILE__, name
        
        require 'pathname'
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

        # Makes a very very pretty and human readable string representation of
        # this bbw
        def to_s
          result = "BuddyBook:\n"
          each { |bid, entry| result.concat("    %s\n" % entry) }
          result
        end

        # Stores the BuddyBook and all its internal information to the 
        # specified file path. If the path does not exist it gets created.
        # If it is not writable for any reason, the usual IO exception and
        # errors will be raised.
        def store_to_file(store_file_path)
          out_path = Pathname(store_file_path)
          def (out = File.open(out_path.to_path, File::CREAT|File::TRUNC|
              File::WRONLY, 0600)).write0(data)
                                     write(data.to_s)
                                     write("\x00")
          end
          for id, entry in self do out.write0(entry.id)
                                   out.write0(entry.addresses.length)
            for address in entry.addresses do out.write0(address.ip)
                                              out.write0(address.port) end
          end
          out.write0("\x00")
        end

        # Loads a buddy book from a storage file, as stored previously by
        # calling #store_to_file (or some hand made bbq-file by someone
        # who knows).
        #
        # If the given file does not exist or it is not readable for any
        # reason, the usual IO exceptions and errors will be raised.
        def load_from_file(load_file_path)
          in_path = Pathname(load_file_path)
          tokens = in_path.read.split("\x00")
          while !tokens.empty? && !tokens.first.empty? do
            id = tokens.shift
            num_addr = tokens.shift.to_i
            addresses = Array::new(num_addr) {
              ip = tokens.shift
              port = tokens.shift
              Isi::FreeChat::PostOffice::Address::new(ip, port)
            }
            self << (entry = BuddyEntry::new(id, addresses))
          end
        end

        Isi::db_bye __FILE__, name
      end
    end
  end
end
