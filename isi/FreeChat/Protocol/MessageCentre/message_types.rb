module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        module MessageTypes
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
