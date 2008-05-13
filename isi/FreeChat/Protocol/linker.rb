module Isi
  module FreeChat
    module Protocol
      module Linker
        Isi::db_hello __FILE__, name

        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last

        # require all files for this module
        require ModuleRootDir + 'linker'

        Isi::db_bye __FILE__, name
      end
    end
  end
end
