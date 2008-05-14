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
        # * message_receivers : objects which will be notified when a
        #   packet is received. They must respond_to 'message_received'.
        #   When a message is received that method is called with two
        #   arguments: an Address object, indicating from which address
        #   this packet arrived, and a String containing the binary data
        #   of the packet.
        def initialize my_addr, message_receivers=[]
          # First, create my logger and use it
          @logger = Logger.new STDERR
          @logger.level = Logger::INFO
          # More specific loggers
          @receiver_logger = Logger.new STDERR
          @receiver_logger.level = Logger::WARN
          @server_logger = Logger.new STDERR
          @server_logger.level = Logger::WARN
          
          @connections = {}
          @connections_mutex = Mutex.new
          # Message receivers, must have method 'message_received'
          @message_receivers = (mrs = Array.try_convert(message_receivers) ;
              mrs = message_receivers unless mrs
              if mrs.respond_to?(:to_a) then mrs = mrs.to_a
                                        else mrs = Array[mrs]
                                        end
              )
          @message_receivers_mutex = Mutex.new
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
          @server_socket.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR,
              true
          sockaddr = Socket.pack_sockaddr_in my_addr.port, my_addr.ip
          @server_socket.bind sockaddr
          @server_socket.listen 5
          @server_socket.do_not_reverse_lookup = true
          # Server Thread - servers an incoming connection
          @server_lambda = lambda { |client, addr|
            buffer = ''.encode('utf-8')
            begin
            # Simple protocol: read 4 bytes which tell the length of the
            # message and then read that many byte
            recv client, 4, buffer
            length = Integer::from_bytes(buffer[0..3].bytes.to_a)
            @server_logger.debug('server') { 
              "receiving message of length: #{length} ..."
            }
            # ignore if length is 0
            raise 'Length <= 0' if length <= 0
            
            buffer[0..3] = ''
            recv client, length-buffer.length, buffer
            message = buffer[0..length-1]
            buffer[0..length-1] = ''
            @server_logger.debug('server') {
              "received message: #{message}"
            }
            @message_receivers_mutex.synchronize {
              for mr in @message_receivers do
                mr.message_received addr, message
              end
            }
            @server_logger.debug('server') { 'forwarded to MRs' }
          rescue => e then @server_logger.error('server'){e}
          end while not client.closed?
          }
          # Receiver Thread - listening for incoming connections
          @receiver_lambda = lambda {
            begin
              peer, peer_name = @server_socket.accept_nonblock
              peer.do_not_reverse_lookup = true
              peer_port, peer_ip = Socket.unpack_sockaddr_in peer_name
              addr = Address.new peer_ip, peer_port
              @receiver_logger.debug("Accepted connection from #{addr}")
              lock_connections { |connections|
                connections[addr] = [peer, DateTime.now]
              }
              Thread.new(peer, addr, &@server_lambda)
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
            connections.each { |addr, conn_pair| 
              conn_pair.at(0).close
            }
          }
        end
        
        # === Throws
        # Errno::ECONNREFUSED
        def send_to addr, data
          len_bytes = data.bytesize.bytes
          len_bytes[len_bytes.length .. 3] = Array.new(4-len_bytes.length, 0)
          connection = get_connection addr
          connection.at(0).write s=String::from_bytes(len_bytes)
          connection.at(0).write data
          connection[1] = DateTime.now
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
        
        # Add's the specified message receiver to the list of receivers
        # who will get notified when a packet arrives. The receiver must
        # respond_to method 'message_received'. This method will be called
        # when a packet is received with the following arguments:
        # * An Address object indicating from which Address this packet arrived
        # * A String containing the binary data of the packet
        def add_message_receiver rcvr
          @message_receivers << rcvr
          return nil
        end
        # Removes the specified receiver from the list  of receivers which
        # get notified when a packet arrives. Comparison is done by method
        # '=='.
        def remove_message_receiver rcvr
          @message_receivers.reject! { |mr| mr == rcvr }
          return nil
        end
        
        private ################################################################
        def create_connection addr
          return TCPSocket.new(addr.ip, addr.port)
        end
        
        # Creates _new_ connection data (AND NEW CONNECTION).
        # That is an array in which:
        # * at(0) is a TCPSocket connected to addr
        # * at(1) is a DateTime object for the last time this connection
        #   was used
        def create_connection_data addr
          [create_connection(addr), DateTime.now]
        end
        
        # If connection exists, it returns it. If it does not, it creates it
        # and then returns it.
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
          @logger.debug(c) {'connections lock taken' }
          @connections_mutex.synchronize { yield @connections }
          @logger.debug(c) { 'connections lock left' }
        end
        
        # Reads from +sockin+ (which must be a +Socket+)
        # +len+ number of bytes without blocking,
        # sleeping +Server_sleeping_period+ whenever it has to.
        # Result is stored in +buffer+ by method 'concat'
        # and +buffer+ is returned.
        #
        # Note that buffer might contain much more than +len+ bytes,
        # if there are more bytes available in the socket stream.
        def recv sockin, len, buffer=[]
          buffer.concat(sockin.recvfrom_nonblock(len).at(0))
          raise Errno::EAGAIN if buffer.length < len
        rescue Errno::EAGAIN, Errno::EWOULDBLOCK
          sleep Server_sleeping_period
          retry
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
