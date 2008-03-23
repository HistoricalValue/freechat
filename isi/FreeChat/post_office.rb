module Isi
  module FreeChat
    module PostOffice
      Isi::db_hello __FILE__, name
      
      ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
      
      # require all files for this module
      reqs = ['address']
      for r in reqs do require ModuleRootDir + r end
      
      Isi::db_bye __FILE__, name
    end
  end
end
