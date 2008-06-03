module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        
        class SilenceHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          CommandName = 'silence'
          def initialize silence_setter
            super(CommandName)
            @silence_setter = silence_setter
          end

          def handle(comm)
            @silence_setter[true]
          end
          
          Isi::db_bye __FILE__, name
        end
        
      end
    end
  end
end
