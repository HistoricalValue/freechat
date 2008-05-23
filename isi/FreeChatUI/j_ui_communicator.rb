module Isi
  module FreeChatUI
    require ModuleRootDir + '../FreeChat/FreeChatUI'
    class JUICommunicator < FreeChatUI
      require 'socket'
      include Socket::Constants
      def initialize port
        @socket = Socket::new AF_INET, SOCK_STREAM, 0
        @jui_sockaddr = Socket::pack_sockaddr_in port, 'localhost'
      end
      
      def port
        Socket::unpack_sockaddr_in(@jui_sockaddr).at(0)
      end
      
      def ip
        Socket::unpack_sockaddr_in(@jui_sockaddr).at(1)
      end
      
      def connect_and_serve
        @socket.connect @jui_sockaddr
        # We need two threads, one to receive messages and one to send out
        # the ones we receive as UI.
        
        #TODO add servings here
      end
    end
  end
end
