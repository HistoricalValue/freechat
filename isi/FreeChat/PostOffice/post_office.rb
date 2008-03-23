module Isi
  module FreeChat
    module PostOffice
      class PostOffice
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        require 'socket'
        require 'date'
        
        def initialize
          @connections = {}
        end
        
        # === Throws
        # Errno::ECONNREFUSED
        def send_to addr, data
          connection = get_connection addr
          connection.at(0).write data
        end
        
        # Checks if an address is connectable
        def reachable? addr
          connection = get_connection addr
          return (not connection.nil?)
        rescue Errno::ECONNREFUSED
          return false
        rescue Errno::ETIMEDOUT
          return false
        end
        
        private ################################################################
        def create_connection addr
          return TCPSocket.new(addr.ip, addr.port)
        end
        
        # Creates _new_ connection data. That is an array in which:
        # * at(0) is a TCPSocket connected to addr
        # * at(1) is a DateTime object for the last time this connection
        #   was used
        def create_connection_data addr
          [create_connection(addr), DateTime.now]
        end
        
        def get_connection addr
          unless connection = @connections[addr] then
            connection = (@connections[addr] = create_connection_data addr)
          end
          return connection
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
