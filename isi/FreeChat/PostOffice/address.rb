module Isi
  module FreeChat
    module PostOffice
      class Address
        def initialize ip=nil, port=nil
          @ip = ip.to_s
          @port = port.to_i
        end
        attr_accessor :ip, :port
      end
    end
  end
end
