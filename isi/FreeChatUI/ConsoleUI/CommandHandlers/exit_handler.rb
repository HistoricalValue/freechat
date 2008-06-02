module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        
        class ExitHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          CommandName = 'exit'
          def initialize exit_sync
            super(CommandName)
            @exit_sync = exit_sync
          end

          def handle(comm)
            @exit_sync.value = true
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
