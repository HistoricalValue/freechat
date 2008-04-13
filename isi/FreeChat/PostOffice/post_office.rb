module Isi
  module FreeChat
    module PostOffice
      class PostOffice
        Isi::db_hello __FILE__, name
        
        require 'pathname'
        require 'socket'
        require 'date'
        require 'logger'
        
        include Socket::Constants
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        Cleaner_thread_check_period = 30 # sec
        Idle_connection_idle_time   = 60 # sec
        Idle_connection_idle_time_day_fraction =
            Rational(Idle_connection_idle_time / 24 * 60 * 60)
        Server_sleeping_period      =  1 # sec

        # === Arguments
        # * my_addr : An +Address+ object which indicates our address (to
        #   receive messages to)
        def initialize my_addr
          # First, create my logger and use it
          @logger = Logger.new STDERR
          @logger.level = Logger::INFO
          # Logger can only be used by calling +lock_logger+ method and
          # passing a block which receives the logger as an argument
          @logger_mutex = Mutex.new
          # More specific loggers
          @receiver_logger = Logger.new STDERR
          @receiver_logger.level = Logger::DEBUG
          @server_logger = Logger.new STDERR
          @server_logger.level = Logger::DEBUG
          @server_logger_mutex = Mutex.new
          
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
                if dt >= Idle_connection_idle_time_day_fraction then
                  connection.close
                  to_remove << addr
                end
              }
              to_remove.each { |r| connections[r] = nil }
            }
            sleep Cleaner_thread_check_period
          }
#          @cleaner_thread = Thread.new(&@cleaner_lambda)
          
#          @server_socket = TCPServer.new my_addr.port
          @server_socket = Socket.new AF_INET, SOCK_STREAM, 0
          sockaddr = Socket.pack_sockaddr_in my_addr.port, my_addr.ip
          @server_socket.bind sockaddr
          @server_socket.listen 5
          @server_socket.do_not_reverse_lookup = true
          # Server Thread - servers an incoming connection
          @server_lambda = lambda { |client|
            begin
              @server_logger_mutex.synchronize {
                @server_logger.debug('server') {
                  "Welcome my frined, #{client} ..."
              }}
            rescue Errno::EAGAIN, Errno::EWOULDBLOCK
              sleep Server_sleeping_period
            end
          }
          # Receiver Thread - listening for incoming connections
          @receiver_lambda = lambda {
            begin
              peer, peer_name = @server_socket.accept_nonblock
              peer.do_not_reverse_lookup = true
              @receiver_logger.debug('receiver') {'trying to make address'}
              peer_port, peer_ip = Socket.unpack_sockaddr_in peer_name
              @receiver_logger.debug('receiver') {"#{peer_port.inspect}\n#{peer_ip.inspect}"}
              addr = Address.new peer_ip, peer_port
              @receiver_logger.debug('receiver') {'address made'}
              lock_connections { |connections|
                connections[addr] = peer
              }
              @receiver_logger.debug('receiver') {peer.inspect}
              Thread.new(peer, &@server_lambda)
            rescue Errno::EAGAIN, Errno::EWOULDBLOCK
              sleep Server_sleeping_period
            rescue => e
              @receiver_logger.warn {"Something else@!! #{e.inspect}"}
            end while true
          }
          @receiver_thread = Thread.new(&@receiver_lambda)
        end
        
        def close_down
#          @cleaner_thread.kill
          @receiver_thread.kill
          @server_socket.close
          lock_connections { |connections|
            connections.each { |addr, conn| 
              conn.close
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
          c = caller.first
          lock_logger { |l| l.debug(c) {'connections lock taken' } }
          @connections_mutex.synchronize { yield @connections }
          lock_logger { |l| l.debug(c) { 'connections lock left' } }
        end
        
        def lock_logger
          @logger_mutex.synchronize {
            c = caller.first
            @logger.debug(c) { 'logger lock taken' }
            yield @logger
            @logger.debug(c) { 'logger lock left'  }
          }
        end
        Isi::db_bye __FILE__, name
      end
    end
  end
end
