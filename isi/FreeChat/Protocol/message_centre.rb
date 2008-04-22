module Isi
  module FreeChat
    module MessageCentre
      Isi::db_hello __FILE__, name
      
      ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
      
      # require all files for this module
      reqs = ['message_centre', 'message']
      for req in reqs do require ModuleRootDir + req end
      
      Isi::db_bye __FILE__, name
    end
  end
end
