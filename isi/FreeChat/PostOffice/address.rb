module Isi
  module FreeChat
    module PostOffice
      class Address
        Isi::db_hello __FILE__, name 
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        def initialize ip=nil, port=nil
          @ip = ip.to_s
          @port = port.to_i
        end
        attr_accessor :ip, :port
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
