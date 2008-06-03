module Isi
  module FreeChatUI
    module ConsoleUI
      module SystemInterpreters
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        require ModuleRootDir + 'bitch_interpreter'
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
