module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        require ModuleRootDir + 'exit_handler'
        require ModuleRootDir + 'help_handler'
        require ModuleRootDir + 'list_handler'
        require ModuleRootDir + 'window_handler'
        require ModuleRootDir + 'silence_handler'
        require ModuleRootDir + 'speak_handler'
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
