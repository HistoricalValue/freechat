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
        
        def to_s
          "#{ip}:#{port}"
        end
        
        # Returns true if those two addresses have the same IP and port
        def eql? other
#          puts "#{self.inspect}(#{self.object_id}).eql? #{other.inspect}" +
#              "(#{other.object_id})"
          return false unless other.is_a?(self.class)
          return @ip.eql?(other.ip) && @port.eql?(other.port)
        end
        alias_method(:==,  :eql?)
        alias_method(:===, :eql?)
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
