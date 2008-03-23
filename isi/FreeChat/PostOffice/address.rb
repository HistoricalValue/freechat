module Isi
  module FreeChat
    module PostOffice
      class Address
        Isi::db_hello __FILE__, name 
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        require 'resolv'
        
        def initialize ip=nil, port=nil
          @port = port.to_i
          # perform some normalization for ip
          @ip = Resolv::IPv4::create(ip.to_s).to_s
        end
        attr_accessor :ip, :port
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
