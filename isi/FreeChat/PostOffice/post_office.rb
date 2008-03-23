module Isi
  module FreeChat
    module PostOffice
      class PostOffice
        Isi::db_hello __FILE__, name
        
        require 'pathname'
        require 'socket'
        require 'date'
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        cleaner_thread_check_period = 30 # sec
        idle_connection_idle_time   = 60 # sec
        idle_connection_idle_time_day_fraction =
            Rational(idle_connection_idle_time / 24 * 60 * 60)
        server_sleeping_period      =  1 # sec

        # === Arguments
        # * my_addr : An +Address+ object which indicates our address (to
        #   receive messages to)
        def initialize my_addr
          @connections = {}
          @connections_mutex = Mutex.new
          # Clearing Thread - check for idle connections and close them
          @cleaner_lambda = lambda {
            to_remove = []
            now = DateTime.now
            lock_connections { |connections|
              connections.each { |addr, conn_pair|
                connection, last_used = conn_pair
                dt = now - last_used
                if dt >= idle_connection_idle_time_day_fraction then
                  connection.close
                  to_remove << addr
                end
              }
              to_remove.each { |r| connections[r] = nil }
            }
            sleep cleaner_thread_check_period
          }
          @cleaner_thread = Thread.new(&@cleaner_lambda)
          
          @server_socket = TCPServer.new my_addr.port
          # Receiver Thread - listening for incoming messages
          @receiver_lambda = lambda {
            begin
              s = @server_socket.accept_nonblock
            rescue Errno::EAGAIN, Errno::EWOULDBLOCK
              sleep server_sleeping_period
            end while true
          }
          @receiver_thread = Thread.new(&@receiver_lambda)
        end
        
        def close_down
          @cleaner_thread.kill
          @receiver_thread.kill
          @server_socket.close
          lock_connections { |connections|
            connections.each { |addr, conn_pair| 
              conn_pair.at(0).close
            }
          }
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
          connection = nil
          lock_connections { |connections|
            unless connection = connections[addr] then
              connection = (connections[addr] = create_connection_data addr)
            end
          }
          return connection
        end
        
        def lock_connections
          @connections_mutex.synchronize {
            yield @connections
          }
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
